class TimeStationsController < DashboardController
  before_action :set_time_station, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :except => :index
  add_breadcrumb "Dashboard", :dashboard_path , :only => %w(index show)
  add_breadcrumb "Time Station", :time_stations_path , :only => %w(index show)
  # GET /time_stations
  # GET /time_stations.json
  def index
    @current_user = current_user
    @in_times = TimeStation.where(user_id: @current_user.id, parent_id: nil).includes(:children).order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
  end

  # GET /time_stations/1
  # GET /time_stations/1.json
  def show
  end

  # GET /time_stations/new
  def new
    @time_station = TimeStation.new
    @recent = TimeStation.recent(current_account).includes(:user).paginate(:page => params[:page], :per_page => 10)
  end

  # GET /time_stations/1/edit
  def edit
  end

  # POST /time_stations
  # POST /time_stations.json
  def create
    @user = current_account.users.find_by_pin_code(params[:pin_code])
    @last_time_station = TimeStation.where(user: @user).last
    @is_in = true
    if @user
      if @last_time_station.nil? or !@last_time_station.parent_id.nil?
        TimeStation.create(user_id: @user.id)
      elsif @last_time_station.parent_id.nil? 
        TimeStation.create(user_id: @user.id, parent_id: @last_time_station.id, total_time: Time.zone.now - @last_time_station.created_at )
        @is_in = false
      end
    end
  end

  # PATCH/PUT /time_stations/1
  # PATCH/PUT /time_stations/1.json
  def update
    if current_user.is_administrator?
      new_time = Time.zone.parse(params[:time_station][:created_at])
      @time_station.created_at = new_time
      if @time_station.is_checkout?
        @time_station.total_time = new_time - @time_station.parent.created_at
      end
      unless @time_station.save
        render js: "alert('It could not be saved')"
      end
    end
  end

  # DELETE /time_stations/1
  # DELETE /time_stations/1.json
  def destroy
    if current_user.is_administrator?
      unless @time_station.destroy
        render js: "alert('It could not be saved')"
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_time_station
    @time_station = TimeStation.find(params[:id])
  end

end
