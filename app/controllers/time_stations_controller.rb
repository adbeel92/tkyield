class TimeStationsController < DashboardController
  before_action :set_time_station, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :except => :index
  add_breadcrumb "Dashboard", :dashboard_path , :only => %w(index show)
  add_breadcrumb "Time Station", :time_stations_path , :only => %w(index show)
  # GET /time_stations
  # GET /time_stations.json
  def index
    @current_user = current_user
    if @current_user
      @in_times = TimeStation.where(user_id: @current_user.id, parent_id: nil).includes(:children).order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
    end
  end

  # GET /time_stations/1
  # GET /time_stations/1.json
  def show
  end

  # GET /time_stations/new
  def new
    @time_station = TimeStation.new
    @recent = TimeStation.recent(current_account).paginate(:page => params[:page], :per_page => 10)
  end

  # GET /time_stations/1/edit
  def edit
  end

  # POST /time_stations
  # POST /time_stations.json
  
  def create
    @user = current_account.users.find_by_pin_code(params[:pin_code])
    @success = true
    if @user and !@user.archived?
      @in_time, @out_time, @total_time = @user.check_in_or_out
    else
      @success = false
    end
  end

  # PATCH/PUT /time_stations/1
  # PATCH/PUT /time_stations/1.json
  def update
    respond_to do |format|
      if @time_station.update(time_station_params)
        format.html { redirect_to @time_station, notice: 'Time station was successfully updated.' }
        format.json { render :show, status: :ok, location: @time_station }
      else
        format.html { render :edit }
        format.json { render json: @time_station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_stations/1
  # DELETE /time_stations/1.json
  # def destroy
  #   @time_station.destroy
  #   respond_to do |format|
  #     format.html { redirect_to time_stations_url, notice: 'Time station was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_time_station
      @time_station = TimeStation.find(params[:id])
    end

end
