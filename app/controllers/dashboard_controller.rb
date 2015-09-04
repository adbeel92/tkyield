# encoding: utf-8
class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_current_user

  def default_url_options(options={})
    { route: current_account ? current_account.subdomain : nil }
  end

  private
    def validate_current_user
      if current_user and current_user.archived?
        #redirect_to destroy_user_session_path
        redirect_to :back
        sign_out current_user


      end
      return
    end
end