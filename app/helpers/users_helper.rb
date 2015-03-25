module UsersHelper
	def users_helper
		User.all.order("first_name, last_name ASC")
	end
end
