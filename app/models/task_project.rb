class TaskProject < ActiveRecord::Base
  belongs_to :project
  belongs_to :task

  validates_uniqueness_of :project_id, scope: :task_id
end
