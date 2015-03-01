class Project < ActiveRecord::Base
  belongs_to :client
  has_many :timesheets
  has_many :task_projects, dependent: :destroy
  has_many :tasks, :through => :task_projects
  has_many :user_projects, dependent: :destroy
  has_many :users, :through => :user_projects

  delegate :name, :to => :client, :prefix => true

  validates :client, :name, :description, presence: true
  has_many :timesheets
  acts_as_xlsx
  
  accepts_nested_attributes_for :task_projects, :allow_destroy => true, :reject_if => proc { |t| t['task_id'].blank? }
  accepts_nested_attributes_for :user_projects, :allow_destroy => true, :reject_if => proc { |t| t['user_id'].blank? }

  #, :reject_if => proc { |a| a['task_id'].blank? }
  #accepts_nested_attributes_for :tasks, :allow_destroy => true #, :reject_if => proc { |a| a['task_id'].blank? }

  def project_total_time 
    Timesheet.where(project_id: self.id).sum(:total_time)
  end
  
end
