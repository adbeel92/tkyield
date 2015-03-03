class AddProjectsIndexes < ActiveRecord::Migration
  def change
    add_index :task_projects, [:task_id, :project_id], unique: true
    add_index :user_projects, [:user_id, :project_id], unique: true
  end
end
