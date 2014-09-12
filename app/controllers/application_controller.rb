class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :set_cache_buster
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit :username, :name, :phone_number, :email, :password, :password_confirmation
      end
    end

end
