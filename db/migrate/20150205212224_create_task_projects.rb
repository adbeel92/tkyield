class CreateTaskProjects < ActiveRecord::Migration
  def change
    create_table :task_projects do |t|
      t.integer :task_id
      t.integer :project_id
      t.timestamps null: false
    end
  end
end
