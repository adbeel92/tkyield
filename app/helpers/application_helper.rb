module ApplicationHelper

	def get_seconds_in_hours_minutes time
		# Time.at(time).utc.strftime("%H:%M")
		minutes = (time / 60) % 60
		hours = time / (60 * 60)

		format("%02d:%02d", hours, minutes)
	end

	def get_date_in_day_format date
		date.strftime("%A")
	end
end
