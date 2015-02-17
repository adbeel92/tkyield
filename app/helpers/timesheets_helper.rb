module TimesheetsHelper

	def projects_helper
		current_user.projects
	end

	def new_timesheet
		Timesheet.new
	end

end
