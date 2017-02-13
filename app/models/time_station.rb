# == Schema Information
#
# Table name: time_stations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  total_time :float(24)        default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#

class TimeStation < ActiveRecord::Base
  belongs_to :user
  belongs_to :parent, :class_name => 'TimeStation'
  has_one :children, :class_name => 'TimeStation', :foreign_key => 'parent_id'

  acts_as_xlsx

  def is_checkin?
    parent_id.nil?
  end

  def is_checkout?
    !parent_id.nil?
  end

  def self.in_current_month_per_user(date, user)
    where(user: user, created_at: date.beginning_of_month..date.end_of_month)
  end

  def self.between_dates_and_user(beginning, ending, user)
    between_dates_and_users(beginning, ending, [user])
  end

  def self.between_dates_and_users(beginning, ending, users)
    where(user: users, created_at: beginning.beginning_of_day..ending.end_of_day).order("created_at DESC")
  end

  def self.total_in_dates(time_stations)
    in_time_stations = time_stations.select{|x| x.parent_id.nil? }
    out_time_stations = time_stations.select{|x| !x.parent_id.nil? }
    out_time_stations_by_date = out_time_stations.group_by{|x| x.created_at.strftime("%m/%d/%Y")}
    total_in_dates = {}
    different_day = []
    out_time_stations_by_date.each_pair do |key, value|
      same_day = []
      value.each do |ot|
        it = in_time_stations.select{ |t| t.id == ot.parent_id }.first
        unless it.nil?
          if ot.created_at.strftime("%m/%d/%Y") == it.created_at.strftime("%m/%d/%Y")
            same_day << ot
          else
            different_day << { in_time_format: it.created_at.strftime("%m/%d/%Y"), total_time: ot.total_time, days: (ot.created_at.to_date - it.created_at.to_date) }
          end
        else
          different_day << { in_time_format: ot.created_at.strftime("%m/%d/%Y"), total_time: ot.total_time, days: 0 }
        end
      end
      total_in_dates[key] = { same_day: same_day, total_same_day: same_day.inject(0){|sum,t| sum += t.total_time } }
    end
    total_in_dates[:different_day] = different_day
    total_in_dates[:total] = time_stations.inject(0){|sum,t| sum += t.total_time }
    return total_in_dates
  end

  def self.total_in_dates_by_users(time_stations, users)
    total_in_dates_by_users = {}
    users.each { |user| total_in_dates_by_users["#{user.full_name}"] = total_in_dates(time_stations.select{ |t| t.user_id == user.id }) }
    return total_in_dates_by_users
  end

  def self.recent(account)
    find_by_account(account).order("time_stations.created_at DESC")
  end

  def self.find_by_account(account)
    self.joins(:user).where(users: { account_id: account.id })
  end
  def get_event_logs
    hash_events = EventLog.last_event(created_at.strftime("%Y-%m-%d"))
    hash_events.select{ |event| event.edited? }
   end
  def self.get_inTime_events(event_logs_array)
    inTime = "24:59"
    event_logs_array.each do |event_log|
      if event_log.inTime < inTime
        inTime = event_log.inTime
      end
    end
    return inTime.to_time.strftime("%l:%M %p")
  end
  def self.get_outTime_events(event_logs_array)
    outTime = "00:01"
    event_logs_array.each do |event_log|
      if event_log.outTime > outTime
        outTime = event_log.outTime
      end
    end
    return outTime.to_time.strftime("%l:%M %p")
  end

  def self.get_arrive_status current_timeStation
    #10 minutos de tolerancia
    inTime_events = TimeStation.get_inTime_events(current_timeStation.get_event_logs)
    inTime_timeStation = (current_timeStation.created_at - 600 ).strftime("%k:M")  
    if inTime_timeStation <= inTime_events
      return "atTime"
    else
      return "late"
    end
  end

  def self.get_offset_worked_hours(time,in_Out,event_logs_array)
    time = time.strftime("%H:%M").split(':')
    time_seconds = (time[0].to_i) * 60 * 60 + (time[1].to_i) * 60
    if in_Out.nil?
      timeIn_Out = TimeStation.get_inTime_events(event_logs_array).to_datetime.strftime("%H:%M").split(':')
      timeIn_Out_Seconds = (timeIn_Out[0].to_i) * 60 * 60 + (timeIn_Out[1].to_i) * 60 
    else
      timeIn_Out = TimeStation.get_outTime_events(event_logs_array).to_datetime.strftime("%H:%M").split(':')
      timeIn_Out_Seconds = (timeIn_Out[0].to_i) * 60 * 60 + (timeIn_Out[1].to_i) * 60 
    end
    offset = ( time_seconds - timeIn_Out_Seconds) / 60 #minutes
    status = ""
    if (offset > 0 )
      status = "late"
    else
      status = "early"
    end
    return offset, status
  end

  def self.get_checkIn_checkOut(information_of_month, date, month)
    if date.between?(month.beginning_of_month,month.end_of_month)
      time_station_in = information_of_month[date.strftime("%e").to_i]["inTime"]
      time_station_out = information_of_month[date.strftime("%e").to_i]["outTime"]
      unless time_station_in.nil?
        time_station_in = time_station_in.created_at.strftime("%H:%M %p")
      end
      unless time_station_out.nil?
        time_station_out = time_station_out.created_at.strftime("%H:%M %p")
      end
      return time_station_in, time_station_out
    else
      return nil, nil
    end
  end

  def get_total_hours 
    return ( (self.created_at - TimeStation.find(self.parent_id).created_at) / 3600 ).to_d.truncate(2).to_f
  end  

end

