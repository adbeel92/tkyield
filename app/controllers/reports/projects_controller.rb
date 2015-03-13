module Reports
  class ProjectsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_time
    add_breadcrumb "Dashboard", :root_path 
    add_breadcrumb "Reports", :reports_list_path 
    add_breadcrumb "Timesheet Report", :reports_dash_path
    
    def show
      @project = Project.find params[:id]
      add_breadcrumb "Projects", :reports_project_path
      @time = Timesheet.where(belongs_to_day: @beginning..@end,project: @project).includes(:user).order("belongs_to_day ASC")
      respond_to do |format|
        format.html
        format.js
        format.xlsx
      end
    end

    private 

    def set_time
      @today = Time.zone.now.to_date
      @day_selected = ( params[:date] ) ? DateTime.parse(params[:date]) : @today
      @type = (params[:type]) ? params[:type] : "Weekly"
      @tab = (params[:tab]) ? params[:tab] : "tab1"
      if @type == "Weekly"
        @beginning = @day_selected.at_beginning_of_week 
        @end = @day_selected.at_end_of_week
      elsif @type == "Monthly"
        @beginning = @day_selected.at_beginning_of_month
        @end = @day_selected.at_end_of_month
      end
    end
  end
end