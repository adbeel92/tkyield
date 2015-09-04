# encoding: utf-8
class Api::ApiV1Controller < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token
  before_filter :verify_current_user
  helper_method :current_user

  respond_to :json

  def verify_current_user
    access_token = request.headers["HTTP_AUTHORIZATION"]
    if access_token
      @current_user ||= User.find_by_access_token(access_token)
      if @current_user.nil? or @current_user.archived?
        render json: { success: false, error: "You are unauthorized to perform this action" }, status: 401
      end
    end
    return
  end

  private

    def current_user
      @current_user
    end

end
