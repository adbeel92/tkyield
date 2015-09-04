class Api::V1::TimeStationsController < Api::ApiV1Controller

  def create
    if current_user
      account = current_user.account
      @user = account.users.find_by(user_params)
      if @user and !@user.archived?
        @in_time, @out_time, @total_time = @user.check_in_or_out
      else
        render json: { success: false, error: "Pin/QR code is invalid" }, status: 401
      end
    else
      render json: { success: false, error: "The use account is invalid" }, status: 404
    end
  end
  
  private

  def user_params
    params.permit(:qr_code, :pin_code)
  end

end
