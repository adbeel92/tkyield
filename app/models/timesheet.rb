class Timesheet < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :project , -> { with_deleted }
  belongs_to :task, -> { with_deleted }
  belongs_to :user

  delegate :name, :to => :project, :prefix => true
  delegate :name, :to => :task, :prefix => true

  validates :project, :task, :user, presence: true

  def toggle_timer
    is_running? ? stop_timer : start_timer
  end

  def is_running?
    self.running
  end

  def start_timer
    self.running = true
    self.start_time = Time.zone.now
    self.save
  end

  def stop_timer
    self.running = false
    self.stop_time = Time.zone.now
    self.total_time += calculate_difference
    self.save
  end

  def calculate_difference
    self.total_time = (self.stop_time - self.start_time).to_f
    return self.total_time
  end

  def current_time
    if running?
      now = Time.zone.now
      time_elapsed = (now - self.start_time).to_f
      return (total_time + time_elapsed).round(0)
    else
      return total_time.round(0)
    end
  end

  def save_with_parse_total param_total_time
    if param_total_time.match(/\A(([0-9\ ]+)|([0-9\ ]+[:.])|([0-9\ ]+[:.][0-9\ ]+)|([:.][0-9\ ]+))\z/)
      if param_total_time.include? "."
        percentage = param_total_time.to_f
        self.total_time = percentage * 3600
      elsif param_total_time.include? ":"
        timeArray = param_total_time.split(":")
        hoursInSeconds = timeArray[0].to_f * 3600
        minutesInSeconds = timeArray[1].to_f * 60
        self.total_time = hoursInSeconds + minutesInSeconds
      else
        self.total_time = param_total_time.to_f * 3600
      end
      self.save
    elsif param_total_time.blank?
      self.total_time = 0
      self.save
    else
      false
    end
  end

  def self.days_of_week_by_date(date)
    start_of_week_day = date.beginning_of_week
    days_of_week = []
    (0..6).each{ |index| days_of_week << start_of_week_day + index.days }
    return days_of_week
  end

  def self.total_time_in_projects_by_user(user)
    user.timesheets.select("timesheets.project_id, timesheets.user_id, SUM( timesheets.total_time ) AS total").joins(:user).group("timesheets.project_id")
  end

  def self.total_time_in_users_by_project(project)
    project.timesheets.select("timesheets.user_id, timesheets.project_id, SUM( timesheets.total_time ) AS total").joins(:project).group("timesheets.user_id")
  end

end
