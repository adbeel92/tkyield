module Reports
  class ReportsController < DashboardController
    before_action :set_time
    before_action :set_account_users, only: [:clients_excel, :projects_excel, :collaborators_excel]
    add_breadcrumb "Dashboard", :dashboard_path 
    
    def index
      add_breadcrumb "Reports", :reports_list_path
    end

    def dash
      add_breadcrumb "Reports", :reports_list_path
      add_breadcrumb "Timesheet Report", :reports_dash_path
      @clients = current_account.clients.between_dates(@beginning, @end).order("name")
      
      @projects = current_account.projects.between_dates(@beginning, @end).includes(:client).order("name")
      @users = current_account.users.between_dates_and_team(@beginning, @end, @selected_team).order("first_name, last_name")
      @teams = current_account.teams.order("name")
    end

    def tables
      @to_report = [["Clients",1], ["Projects",2], ["Teams",3], ["Collaborators",4]]
      @report_type = [["xDay",1],["xCollaborator",2],["xProject",3],["CsxD",4],["TsxD",5],["PsxD",6]]
      @clients = current_account.clients.select(:id, :name).order("name ASC")
      @projects = current_account.projects.includes(:client).order("name")
      @users = current_account.users.select(:id, :first_name, :last_name).order("first_name, last_name")
      @teams = current_account.teams.select(:id, :name).order("name")
    end

    def clients_excel
      @timesheet = timesheet.order("clients.name")
      respond_to do |format|
        format.xlsx {response.headers['Content-Disposition'] = "attachment; filename=' Clients Report.xlsx'"}
      end
    end

    def projects_excel
      @timesheet = timesheet.order("projects.name")
      respond_to do |format|
        format.xlsx {response.headers['Content-Disposition'] = "attachment; filename='Projects Report.xlsx'"}
      end
    end

    def collaborators_excel
      unless params[:teamId].blank?
        @users = @users.where(team_id: @selected_team)
      end
      @timesheet = timesheet.order("users.first_name, users.last_name")
      respond_to do |format|
        format.xlsx {response.headers['Content-Disposition'] = "attachment; filename='Collaborators Report.xlsx'"}
      end
    end

    def timesheet
      Timesheet.where(belongs_to_day: @beginning..@end, user: @users).includes(:task, :user, project: [:client]).order("belongs_to_day ASC")
    end

    private 

      def set_account_users
        @users = current_account.users
      end

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
        @selected_team = current_account.teams.find(params[:teamId]) if !params[:teamId].blank?
      end

  end
end