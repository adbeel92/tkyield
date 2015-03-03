class Task < ActiveRecord::Base
  has_many :task_projects
  has_many :projects, :through => :task_projects
  has_many :timesheets

  validates :name, presence: true
end
