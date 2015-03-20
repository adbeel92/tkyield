module ClientsHelper
	def clients_helper
		Client.all.order("name ASC")
	end
end
