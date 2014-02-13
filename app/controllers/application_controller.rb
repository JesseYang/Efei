require 'string'
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'layouts/user'

  before_filter :set_flash
  before_filter :store_location

  def set_flash
    @flash = params[:flash]
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    if (request.fullpath != "/users/sign_in" &&
        request.fullpath != "/users/sign_up" &&
        request.fullpath != "/users/password" &&
        request.fullpath != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to new_user_session_path and return if current_user.blank?
      end
      format.json do
        if current_user.blank?
          render json: { success: false, reason: "require sign in" } and return
        end
      end
    end
  end

  def require_admin
    redirect_to new_user_session_path if current_user.try(:admin) != true
  end

  def after_sign_in_path_for(resource)
    if current_user.try(:admin)
      session[:previous_url] || admin_homeworks_path
    else
      session[:previous_url] || user_questions_path
    end
  end

  def user_sign_in?
    current_user.present?
  end

  def user_admin?
    current_user.try(:admin)
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_500
    raise '500 exception'
  end
end
