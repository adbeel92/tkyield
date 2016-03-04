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

end
