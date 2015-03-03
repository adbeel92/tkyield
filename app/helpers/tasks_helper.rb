module TasksHelper
	def tasks_helper
		Task.all.order("name ASC")
	end
end
