class Event < ActiveRecord::Base
  validates_with TimeValidator
  belongs_to :schedule
  validates :inTime, presence: true
  validates :outTime, presence: true

  enum day_of_week: [:Mon, :Tue, :Wed, :Thu, :Fri, :Sat, :Sun]

  def day(day)
    where(day_of_week: day)
  end

  def belongs_at_this_time(hour)
    current_hour = (7+hour)
    start = self.inTime.to_time.strftime("%H:%M").split(':')
    start = (start[0].to_i)
    return (current_hour == start)
  end

  def get_factor
    start = self.inTime.to_time.strftime("%H:%M").split(':')
    start = (start[0].to_i)*60 + (start[1].to_i)
    finish = self.outTime.to_time.strftime("%H:%M").split(':')
    finish = (finish[0].to_i)*60 + (finish[1].to_i)
    return ( finish - start  ) / 60.0
  end

  def self.events_duration_array(events)
    array = Array.new
    events.each do |current_event|
      events_duration = Hash.new
      start_inTime = current_event.inTime.to_time.strftime("%H:%M").split(':')
      events_duration["id"] = start_inTime[0].to_i.to_s + "-" + (current_event[:day_of_week]+1).to_s
      events_duration["factor"] = current_event.get_factor
      events_duration["row"] = start_inTime[0]
      events_duration["col"] = (current_event[:day_of_week]+1).to_s
      array.push(events_duration)
    end
    return array
  end


end
