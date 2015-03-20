require 'test_helper'

class TimeStationsControllerTest < ActionController::TestCase
  setup do
    @time_station = time_stations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:time_stations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create time_station" do
    assert_difference('TimeStation.count') do
      post :create, time_station: { in_time: @time_station.in_time, out_time: @time_station.out_time, total_time: @time_station.total_time, user_id: @time_station.user_id }
    end

    assert_redirected_to time_station_path(assigns(:time_station))
  end

  test "should show time_station" do
    get :show, id: @time_station
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @time_station
    assert_response :success
  end

  test "should update time_station" do
    patch :update, id: @time_station, time_station: { in_time: @time_station.in_time, out_time: @time_station.out_time, total_time: @time_station.total_time, user_id: @time_station.user_id }
    assert_redirected_to time_station_path(assigns(:time_station))
  end

  test "should destroy time_station" do
    assert_difference('TimeStation.count', -1) do
      delete :destroy, id: @time_station
    end

    assert_redirected_to time_stations_path
  end
end
