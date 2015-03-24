class Api::V1::TimeStationsController < Api::ApiV1Controller

	def create
		@user = User.find_by_qr_code(params[:qr_code])
		@last_time_station = TimeStation.where(user: @user).last
		@is_in = true
		if @last_time_station.nil? or !@last_time_station.out_time.nil?
			TimeStation.create(user_id: @user.id, in_time: Time.zone.now)
		elsif @last_time_station.out_time.nil?
			@last_time_station.update(out_time: Time.zone.now, total_time: Time.zone.now - @last_time_station.in_time)
			@is_in = false
		end
	end

end
