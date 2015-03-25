module Reports
  class OnTimeController < ApplicationController
    before_action :authenticate_user!
    before_action :set_time
    add_breadcrumb "Dashboard", :root_path 
    add_breadcrumb "Reports", :reports_list_path 
    
    def index
      add_breadcrumb "On Time Report", :reports_on_time_index_path
      
      @filtered_users = User.all.order("first_name, last_name")
      if !params[:team].blank? and params[:collaborator].blank?
        @filtered_users = User.where(team_id: @selected_team)
      elsif !params[:collaborator].blank?
        @filtered_users = User.where(id: @selected_collaborator)
      end

      @teams = Team.all
      @collaborators = User.order("first_name, last_name")
      
      respond_to do |format|
        format.html
        format.xlsx
      end

    end

    private

    def set_time
    
      @tab = (params[:tab]) ? params[:tab] : "tab1"
      @today = Time.zone.now.to_date
      @selected_team = Team.find(params[:team]) if !params[:team].blank?
      @selected_collaborator = User.find(params[:collaborator]) if !params[:collaborator].blank?
      @beginning = (!params[:beginning].blank?) ? DateTime.strptime(params[:beginning], "%m/%d/%Y") : @today.at_beginning_of_week 
      @end = (!params[:end].blank?) ? DateTime.strptime(params[:end], "%m/%d/%Y") : @today.at_end_of_week
    
    end
  end
end