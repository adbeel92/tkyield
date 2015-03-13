module Reports
  class OnTimeController < ApplicationController
    before_action :authenticate_user!
    before_action :set_time
    add_breadcrumb "Dashboard", :root_path 
    add_breadcrumb "Reports", :reports_list_path 
    
    def index
      add_breadcrumb "On Time Report", :reports_on_time_index_path
      @in_times = TimeStation.where(created_at: @beginning..@end,parent_id: nil).includes(:children)
      if params[:team]
        @in_times = @in_times.joins(:user).where(:users => { :team_id => @selected_team}) 
      elsif params[:team] and params [:collaborator]
        @in_times = @in_times.where(user: @selected_collaborator)
      end

      @teams = Team.all
      @collaborators = User.all
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    private

    def set_time
      @tab = (params[:tab]) ? params[:tab] : "tab1"
      @today = Time.zone.now.to_date
      @selected_team = Team.find(params[:team]) if params[:team]
      @selected_collaborator = User.find(params[:collaborator]) if params[:collaborator]
      @beginning = (params[:beginning]) ? Date.parse(params[:beginning]) : @today.at_beginning_of_week 
      @end = (params[:beginning]) ? Date.parse(params[:beginning]) : @today.at_end_of_week
    end
  end
end