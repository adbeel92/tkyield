class RegistrationsController < Devise::RegistrationsController
  add_breadcrumb "Dashboard", :root_path , :only => %w(edit update)
  before_filter :configure_permitted_parameters, only: [:update]

  private
 
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
 
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update).push(:first_name,:last_name)
  end

end