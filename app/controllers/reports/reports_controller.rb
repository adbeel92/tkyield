module Reports
  class ReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_time
    add_breadcrumb "Dashboard", :root_path 
    
    def index
      add_breadcrumb "Reports", :reports_list_path
      @clients = Client.order("name ASC").all
      @users = User.order("first_name, last_name ASC").includes(:role)
      @projects = Project.order("name ASC").all.includes(:client)
    end

    def staff
      add_breadcrumb "Reports", :reports_list_path
      add_breadcrumb "Staff Report", :reports_staff_path
      @time_stations = TimeStation.all.includes(:user)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def dash
      add_breadcrumb "Reports", :reports_list_path
      add_breadcrumb "Timesheet report", :reports_dash_path
      @clients = Client.all
      @users = User.all
      @projects = Project.all.includes(:client)
    end

    def clients_excel
      @clients = Client.order("name ASC").all
      respond_to do |format|
        format.xlsx
      end
    end

    def projects_excel
      @projects = Project.order("name ASC").all.includes(:client)
      respond_to do |format|
        format.xlsx
      end
    end

    def collaborators_excel
      @users = User.order("first_name, last_name ASC").includes(:role)
      respond_to do |format|
        format.xlsx
      end
    end

    private 

    def set_time
      @today = Time.zone.now.to_date
      @day_selected = ( params[:date] ) ? DateTime.parse(params[:date]) : @today
      @beginning = @day_selected.at_beginning_of_week 
      @end = @day_selected.at_end_of_week
    end

  end
end