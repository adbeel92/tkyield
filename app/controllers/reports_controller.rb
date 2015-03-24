class ReportsController < ApplicationController
	before_action :authenticate_user!
  	add_breadcrumb "Dashboard", :root_path 
  
  	def index
  		add_breadcrumb "Reports", :reports_path
  	end


end
