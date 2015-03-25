class AddParentIdToTimeStations < ActiveRecord::Migration
  def up
  	remove_column :time_stations, :in_time, :datetime
  	remove_column :time_stations, :out_time, :datetime
  	add_column :time_stations, :parent_id, :integer
  end
  def down
  	add_column :time_stations, :in_time, :datetime
  	add_column :time_stations, :out_time, :datetime
  	remove_column :time_stations, :parent_id, :integer
  end
end
