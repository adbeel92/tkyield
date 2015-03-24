module TimeStationsHelper

	def days_between_dates(beginning, ending)
		i =  (ending - beginning).to_i
	    days_of_week = []
	    (0..i).each{ |index| days_of_week << beginning + index.days }
	    return days_of_week
	end

end
