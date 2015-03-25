class TaskProject < ActiveRecord::Base
  #self.primary_key = :task_id,:project_id
  # validates :project, :task , presence: true
  belongs_to :project
  belongs_to :task
  #validates_uniqueness_of :project_id, :scope => :task_id
  validates_uniqueness_of :task_id, :scope => [:project_id]
end
