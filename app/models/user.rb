# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string(255)      default(""), not null
#  last_name              :string(255)      default(""), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  role_id                :integer
#  qr_code                :string(255)
#  pin_code               :integer
#  team_id                :integer
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  account_id             :integer
#  access_token           :string(255)
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, 
          :trackable, :confirmable, authentication_keys: [ :email, :account_id ]
  scope :active, -> {where(archived_at: nil)}
  scope :archived, -> {where.not(archived_at: nil)}
  scope :without_team, -> {where(team_id: nil)}
  belongs_to :account
  belongs_to :role
  belongs_to :team
  has_many :timesheets
  has_many :time_stations
  has_many :user_projects, dependent: :destroy
  has_many :projects, :through => :user_projects
  has_one :last_time_station, -> { order 'created_at desc' }, class_name: "TimeStation"
  
  delegate :name, :to => :role, :prefix => true, allow_nil: true
  delegate :name, :to => :team, :prefix => true, allow_nil: true
  delegate :company_name, :to => :account, :prefix => true, allow_nil: true
  
  accepts_nested_attributes_for :user_projects, :allow_destroy => true, :reject_if => proc { |t| t['project_id'].blank? }
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/missing.png"
  
  validates :account, presence: true
  validates :role, presence: true
  validates_uniqueness_of   :email,    :case_sensitive => false, :allow_blank => true, :if => :email_changed?, scope: :account_id
  validates_format_of       :email,    :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?
  validates_presence_of     :password, :on=>:create, :if => :password_required?
  validates_confirmation_of :password, :on=>:create
  validates_length_of       :password, :within => Devise.password_length, :allow_blank => true
  validates :qr_code, uniqueness: { :allow_blank => true }
  validates_length_of :pin_code, :within => 1..9999, :allow_blank => true
  validates :pin_code, uniqueness: { scope: :account_id }, unless: Proc.new { |u| u.pin_code.blank? }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validate :freeze_role, :on => :update
  before_create :generate_qr_code_and_access_token

  def generate_qr_code_and_access_token
    self.qr_code = "#{SecureRandom.hex}#{self.account_id}#{self.id}#{Time.now.strftime('%d%m%Y%H%M%S')}"
    if self.role_id == Role::ADMINISTRATOR_ID
      self.pin_code = 1
      self.access_token = "#{SecureRandom.hex.tr('+/=', 'xyz')}#{self.account_id}"
    else
      self.pin_code = self.account.users.order("pin_code ASC").last.pin_code.to_i + 1
    end
  end

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
    self.between_dates_and_team_and_projects(beginning, ending, nil, nil)
  end

  def self.filter(team, collaborator)
    if !collaborator.nil?
      self.where(id: collaborator)
    elsif !team.nil?
      self.where(team_id: team)
    else
      self.all
    end
  end

  def pin
    sprintf '%04d', pin_code
  end

  def archived?
    !archived_at.nil?
  end

  def last_check_in_or_out_activity
    TimeStation.where(user: self).last
  end

  def check_in_or_out
    begin
      last_time_station = last_check_in_or_out_activity
      time_station = nil
      if last_time_station.nil? or last_time_station.is_checkout?
        time_station = check_in
        return time_station.created_at, nil, nil
      else
        time_station = check_out(last_time_station)
        return last_time_station.created_at, time_station.created_at, time_station.total_time
      end
    rescue
      return nil, nil, nil
    end
  end

  def archive!
    if self.archived_at.nil?
      self.update_attributes(archived_at: Time.zone.now)
      self.cancel_active_timesheet
      self.check_out
    else 
      false
    end
  end

  def unarchive!
    if self.archived_at.nil?
      false
    else
      self.update_attributes(archived_at: nil)
    end
  end

  def check_in
    self.time_stations.create
  end

  def check_out(check_in_obj=nil)
    time_station = check_in_obj.nil? ? last_check_in_or_out_activity : check_in_obj
    if time_station.is_checkin?
      self.time_stations.create(parent_id: time_station.id, total_time: Time.zone.now - time_station.created_at)
    end
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

  def self.all_inside
    joins(:time_stations).where('time_stations.created_at = (SELECT MAX(time_stations.created_at) FROM time_stations WHERE time_stations.user_id = users.id)').where('time_stations.parent_id IS NULL').group('users.id')
  end

  def self.all_with_tasks_running
    joins(:timesheets).where("timesheets.running = ?", true)
  end

  def is_administrator?
    self.role_id == Role::ADMINISTRATOR_ID
  end

  def administrator?
    self.role_id_was == Role::ADMINISTRATOR_ID
  end

  def is_manager?
    self.role_id == Role::MANAGER_ID
  end

  def is_employee?
    self.role_id == Role::COLLABORATOR_ID
  end

  def is_confirmed?
    self.confirmed_at != nil
  end

  def freeze_role
    if administrator? and role_id_changed?
      errors.add(:role, "cannot be changed")
    end
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
