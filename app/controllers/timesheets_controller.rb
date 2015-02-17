class TimesheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_timesheet, only: [:toggle_timesheet, :update, :destroy]
  add_breadcrumb "Dashboard", :root_path 
  add_breadcrumb "Timesheet", :timesheets_path

  def index
  	@today = Time.zone.now
  	@day_selected = ( params[:date] ) ? Time.parse(params[:date]) : @today 
  	preload_variables
  end  

  def create
    @timesheet = Timesheet.new(timesheet_params)
    @timesheet.user = current_user
    if @timesheet.save_with_parse_total timesheet_params[:total_time]
      current_user.start_timer(@timesheet)
      @day_selected = @timesheet.belongs_to_day
      preload_variables
    else
      render js: "alert('Invalid Parameters')"
    end
  end

  def update
    @timesheet.assign_attributes(timesheet_params)
    if @timesheet.save_with_parse_total timesheet_params[:total_time]
      @day_selected = @timesheet.belongs_to_day
      preload_variables
    else
      render js: "alert('Invalid Parameters')"
    end
  end

  def destroy
    timesheet = @timesheet
    @timesheet.destroy
    respond_to do |format|
      format.html { redirect_to timesheets_path(date:  timesheet.belongs_to_day), notice: 'Timesheet was successfully destroyed.', :method => :post}
    end
  end

  def toggle_timesheet
    current_user.start_timer @timesheet
    @timesheet.save
    render :json => @timesheet.save, :status => :ok
  end

  def preload_variables
    @start_of_week_day = @day_selected.beginning_of_week
    @timesheets = current_user.get_timesheet_per_day @day_selected
    if current_user.projects.any?
      @default_project = current_user.projects.first
      @tasks = @default_project.tasks
    else
      @default_project = nil
      @tasks = []
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_timesheet
    @timesheet = Timesheet.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def timesheet_params
    params.require(:timesheet).permit(:notes,:project_id,:task_id,:user_id,:total_time,:belongs_to_day)
  end

end

