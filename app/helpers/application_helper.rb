module ApplicationHelper
	def get_seconds_in_hours_minutes time
		# Time.at(time).utc.strftime("%H:%M")
		minutes = (time / 60) % 60
		hours = time / (60 * 60)

		format("%02d:%02d", hours, minutes)
	end

	def total_time_excel_format time
		# Time.at(time).utc.strftime("%H:%M")
		hours = time / (60 * 60)		
		format("%.2f", hours)
	end

	def full_date_format date
		date.strftime("%A, %d %b")
	end

	def day_name_format date
		date.strftime("%a %d")
	end

	def month_format date
		date.strftime("%b")
	end

	def year_format date
		date.strftime("%Y")
	end

	def day_and_date_format date
		date.strftime("%A, %m/%d")
	end

	def date_format date
		date.strftime("%m/%d/%Y")
	end

	def date_format_with_hyphen date
		date.strftime("%Y-%m-%d")
	end
	
	def time_format date
		date.strftime("%I:%M %p")
	end

	def datetime_format date
		date.strftime("%B %d, %I:%M %p")
	end

	def timestamp_format date
		date.strftime("%d%m%Y%H%M%S")		
	end
end
