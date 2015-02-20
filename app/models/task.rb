class Task < ActiveRecord::Base
  validates :name, presence: true
  has_many :task_projects
  has_many :projects, :through => :task_projects
  has_many :timesheets
end
