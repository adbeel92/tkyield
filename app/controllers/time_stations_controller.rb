class TimeStationsController < ApplicationController
  before_action :set_time_station, only: [:show, :edit, :update, :destroy]
  add_breadcrumb "Dashboard", :root_path
  add_breadcrumb "Time Station", :time_stations_path
  # GET /time_stations
  # GET /time_stations.json
  def index
    @time_stations = TimeStation.all
    @current_user = current_user
  end

  # GET /time_stations/1
  # GET /time_stations/1.json
  def show
  end

  # GET /time_stations/new
  def new
    @time_station = TimeStation.new
  end

  # GET /time_stations/1/edit
  def edit
  end

  # POST /time_stations
  # POST /time_stations.json
  def create
    @time_station = TimeStation.new(time_station_params)

    respond_to do |format|
      if @time_station.save
        format.html { redirect_to @time_station, notice: 'Time station was successfully created.' }
        format.json { render :show, status: :created, location: @time_station }
      else
        format.html { render :new }
        format.json { render json: @time_station.errors, status: :unprocessable_entity }
      end
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
  def destroy
    @time_station.destroy
    respond_to do |format|
      format.html { redirect_to time_stations_url, notice: 'Time station was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_station
      @time_station = TimeStation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_station_params
      params.require(:time_station).permit(:user_id, :in_time, :out_time, :total_time)
    end
end
