module TimesheetsHelper

	def projects_helper
		current_user.projects
	end

	def new_timesheet
		Timesheet.new
	end

	def date_format_on_view(date)
		date.strftime("%Y-%m-%d")
	end

end
