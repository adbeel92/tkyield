class CreateTimeStations < ActiveRecord::Migration
  def change
    create_table :time_stations do |t|
      t.integer :user_id
      t.datetime :in_time
      t.datetime :out_time
      t.float :total_time, default: 0
      t.timestamps null: false
    end
  end
end
