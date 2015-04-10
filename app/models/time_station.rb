class TimeStation < ActiveRecord::Base
	belongs_to :user
	belongs_to :parent, :class_name => 'TimeStation'
  	has_one :children, :class_name => 'TimeStation', :foreign_key => 'parent_id'
	acts_as_xlsx

	def self.totals_per_day_between_dates( beginning, ending, user)		
		i =  (ending - beginning).to_i
		totals_per_day = []
		(0..i).each{ |index| totals_per_day << TimeStation.where(user: user, created_at: (beginning+index.days).beginning_of_day .. (beginning+index.days).end_of_day ).sum(:total_time) }
		return totals_per_day
	end
  	
  	def self.total_between_dates (beginning, ending, user)
  		TimeStation.where(user: user,created_at: beginning.beginning_of_day .. ending.end_of_day).sum(:total_time)
  	end	

  	
end
