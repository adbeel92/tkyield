class AddDeletedAtToTimesheets < ActiveRecord::Migration
  def change
    add_column :timesheets, :deleted_at, :datetime
    add_index :timesheets, :deleted_at
  end
end