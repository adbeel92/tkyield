module Reports
  class UserProjectController < ApplicationController
    before_action :authenticate_user!
    add_breadcrumb "Dashboard", :root_path 
    add_breadcrumb "Reports", :reports_list_path 
    add_breadcrumb "Timesheet Report", :reports_dash_path
    
    def show
      add_breadcrumb "Collaborator - Project", :reports_user_project_path
      @user = User.find params[:user_id]
      @project = Project.find params[:project_id]
      @timesheets = Timesheet.where(user_id: @user.id, project_id: @project.id).includes(:task)
      @total = @timesheets.inject(0){|sum,e| sum += e.total_time }
    end
  end
end