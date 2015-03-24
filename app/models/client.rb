class Client < ActiveRecord::Base
  has_many :projects

  validates :name, presence: true
  

  def client_total_time_between_dates beginning, ending
  	Timesheet.joins(project: :client).where(belongs_to_day: beginning..ending,projects: {client_id: self.id}).sum(:total_time)
  end

  def total_time
  	Timesheet.joins(project: :client).where(projects: {client_id: self.id}).sum(:total_time)
  end

end
