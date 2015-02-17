class UsersController < ApplicationController
	before_action :authenticate_user!
	add_breadcrumb "Dashboard", :root_path 
	add_breadcrumb "Users", :users_path

	def index
   		@users = User.all
  	end
end