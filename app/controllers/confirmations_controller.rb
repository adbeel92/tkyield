class ConfirmationsController < Devise::ConfirmationsController
  # Remove the first skip_before_filter (:require_no_authentication) if you
  # don't want to enable logged users to access the confirmation page.
  skip_before_filter :require_no_authentication
  skip_before_filter :authenticate_user!

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    if params[:confirmation_token].present?
      @original_token = params[:confirmation_token]
    elsif params[resource_name].try(:[], :confirmation_token).present?
      @original_token = params[resource_name][:confirmation_token]
    end
    self.resource = resource_class.find_by_confirmation_token Devise.token_generator.
      digest(self, :confirmation_token, @original_token)

    super if resource.nil? or resource.confirmed?
  end

  def confirm
    begin
      @original_token = params[resource_name].try(:[], :confirmation_token)
      digested_token = Devise.token_generator.digest(self, :confirmation_token, @original_token)
      self.resource = resource_class.find_by_confirmation_token! digested_token
      resource.assign_attributes(permitted_params) unless params[resource_name].nil?

      if resource.valid? && resource.password_match?
        self.resource.confirm!
        set_flash_message :notice, :confirmed
        sign_in_and_redirect resource_name, resource
      else
        render :action => 'show'
      end
    rescue
      render :action => 'show'
    end
  end

  private
    def permitted_params
     params.require(resource_name).permit(:confirmation_token, :password, :password_confirmation)
    end

end