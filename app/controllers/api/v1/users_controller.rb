class Api::V1::UsersController < Api::ApiV1Controller

	def index
		@users = User.order("first_name, last_name ASC").includes(:role)
	end

end
