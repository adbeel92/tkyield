module ProjectsHelper

	def clients_helper
		Client.all
	end

	def tasks_helper
		Task.all
	end

	def users_helper
		User.all
	end		

end
