class ChangeBelongsToDay < ActiveRecord::Migration
  def up
    change_column :timesheets, :belongs_to_day, :date
  end

  def down
    change_column :timesheets, :belongs_to_day, :datetime
  end
end
