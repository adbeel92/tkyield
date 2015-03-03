module Reports
  class ProjectsController < ApplicationController
    before_action :authenticate_user!
    add_breadcrumb "Dashboard", :root_path 
    add_breadcrumb "Reports", :reports_list_path 
    
    def show
      @project = Project.find params[:id]
      add_breadcrumb "Projects", :reports_project_path
      @timesheets = @project.total_time_in_users
    end
  end
end