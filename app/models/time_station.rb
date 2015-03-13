class TimeStation < ActiveRecord::Base
	belongs_to :user
	belongs_to :parent, :class_name => 'TimeStation'
  	has_one :children, :class_name => 'TimeStation', :foreign_key => 'parent_id'
	acts_as_xlsx
	
	def self.days_of_week_by_date(beginning, ending)
	    i =  (ending - beginning).to_i
	    days_of_week = []
	    (0..i).each{ |index| days_of_week << beginning + index.days }
	    return days_of_week
  	end
  	
end
