module Reports
  class ReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_time
    add_breadcrumb "Dashboard", :root_path 
    
    def index
      add_breadcrumb "Reports", :reports_list_path
    end

    def dash
      add_breadcrumb "Reports", :reports_list_path
      add_breadcrumb "Timesheet Report", :reports_dash_path
      @clients = Client.order("name")
      if !params[:teamId].blank?
        @users= User.where(team_id: @selected_team).order("first_name, last_name")
      else 
        @users = User.order("first_name, last_name")
      end
      @projects = Project.includes(:client).order("name")
      @teams = Team.order("name")
    end

    def clients_excel
      @timesheet = Timesheet.where(belongs_to_day: @beginning..@end).includes(:task,:user,project: [:client]).order("belongs_to_day").order("clients.name")
      respond_to do |format|
        format.xlsx
      end
    end

    def projects_excel
      @timesheet = Timesheet.where(belongs_to_day: @beginning..@end).includes(:task,:user,project: [:client]).order("belongs_to_day ASC").order("projects.name")
      respond_to do |format|
        format.xlsx
      end
    end

    def collaborators_excel
      if !params[:teamId].blank?
        @users= User.where(team_id: @selected_team).order("first_name, last_name")
        @timesheet = Timesheet.where(belongs_to_day: @beginning..@end, user: @users).includes(:task,:user,project: [:client]).order("belongs_to_day ASC").order("users.first_name, users.last_name")
      else 
        @timesheet = Timesheet.where(belongs_to_day: @beginning..@end).includes(:task,:user,project: [:client]).order("belongs_to_day ASC").order("users.first_name, users.last_name")
      end

      respond_to do |format|
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
      @selected_team = Team.find(params[:teamId]) if !params[:teamId].blank?
    end
  end
end