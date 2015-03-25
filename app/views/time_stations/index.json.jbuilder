json.array!(@time_stations) do |time_station|
  json.extract! time_station, :id, :user_id, :in_time, :out_time, :total_time
  json.url time_station_url(time_station, format: :json)
end
