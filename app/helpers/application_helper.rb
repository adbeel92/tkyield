module ApplicationHelper

	def get_seconds_in_hours_minutes time
		# Time.at(time).utc.strftime("%H:%M")
		minutes = (time / 60) % 60
		hours = time / (60 * 60)

		format("%02d:%02d", hours, minutes)
	end

	def day_name_format date
		date.strftime("%A")
	end

	def full_date_format date
		date.strftime("%A, %d %b")
	end
end
