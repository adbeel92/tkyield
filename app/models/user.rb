class User < ActiveRecord::Base
  belongs_to :role
  belongs_to :team
  has_many :timesheets
  has_many :time_stations
  has_many :user_projects, dependent: :destroy
  has_many :projects, :through => :user_projects
  delegate :name, :to => :role, :prefix => true, allow_nil: true
  delegate :name, :to => :team, :prefix => true, allow_nil: true
  accepts_nested_attributes_for :user_projects, :allow_destroy => true, :reject_if => proc { |t| t['project_id'].blank? }
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/missing.png"
  validates :qr_code, uniqueness: true
  validates_length_of :pin_code, :within => 1..9999
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/


  def total_time_between_dates beginning, ending
    Timesheet.where(belongs_to_day: beginning..ending, user_id: self.id).sum(:total_time)
  end

  def self.between_dates_and_team_and_projects beginning, ending, team, projects
    users = self.select("users.*, SUM( timesheets.total_time ) AS total").joins(:timesheets).where("timesheets.belongs_to_day BETWEEN ? AND ?", beginning, ending).group("users.id")
    users = users.where("users.team_id = ?", team.id) unless team.nil?
    users = users.where("timesheets.project_id IN (?)", projects.map{|x| x.id}) unless projects.nil?
    return users
  end

  def self.between_dates_and_projects beginning, ending, projects
    self.between_dates_and_team_and_projects(beginning, ending, nil, projects)
  end

  def self.between_dates_and_project beginning, ending, project
    self.between_dates_and_team_and_projects(beginning, ending, nil, [project])
  end

  def self.between_dates_and_team beginning, ending, team
    self.between_dates_and_team_and_projects(beginning, ending, team, nil)
  end

  def self.between_dates beginning, ending
    self.between_dates_and_team_and_projects(beginning, ending, nil)
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  def total_time
    Timesheet.where(user_id: self.id).sum(:total_time)
  end

  def password_required?
    super if confirmed?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  def is_manager?
    self.role_name == "Manager"
  end

  def is_employee?
    self.role_name == "Employee"
  end

  def is_confirmed?
    self.confirmed_at != nil
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def restart_timer timesheet
    timesheet.start_timer if timesheet.is_running?
  end

  def start_timer timesheet
    if has_a_timer_running?
      cancel_active_timesheet
    end
    timesheet.toggle_timer
  end

  def stop_timer timesheet
    timesheet.toggle_timer
    timesheet.save
  end

  def total_time_per_day_til_now day
    a = 0
    if has_a_timer_running?
      a = get_timesheet_active.current_time 
    end
    a += total_time_per_day day 
  end

  def total_time_per_day day
    get_timesheet_per_day(day).sum(:total_time)
  end

  def total_time_per_week day
    Timesheet.where(belongs_to_day: day.beginning_of_week..day.end_of_week, user_id: self.id).sum(:total_time)
  end

  def get_timesheet_per_day day
    Timesheet.where(belongs_to_day: day, user_id: self.id).includes([:project, :task])
  end

  def timesheets_of_week_by_date date
    days_of_week = Timesheet.days_of_week_by_date(date)
    timesheets = []
    days_of_week.each do |day|
      timesheets << { day: day, timesheets: get_timesheet_per_day(day) }
    end
    return timesheets, timesheets.map{|t| t[:day]}
  end

  def get_timesheet_active
    Timesheet.where(running: true, user_id: self.id)
  end

  def has_a_timer_running?
    !get_timesheet_active.first.nil? 
  end

  def cancel_active_timesheet
    get_timesheet_active.each do |t|
      t.stop_timer
    end
  end

  def total_time_in_projects
    Timesheet.total_time_in_projects_by_user(self)
  end

  def total_time_per_project (project,beginning, ending)
    Timesheet.where(belongs_to_day: beginning..ending,user: self, project: project).sum(:total_time)
  end

  def total_time_per_task (task,beginning, ending)
    Timesheet.where(belongs_to_day: beginning..ending,user: self, task: task).sum(:total_time)
  end

end