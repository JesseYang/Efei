# encoding: utf-8
require 'string'
require 'array'
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

  def require_teacher
    if current_user.try(:teacher) != true
      sign_out(current_user)
      flash[:notice] = "请以教师身份登录"
      redirect_to new_user_session_path
    end
  end

  def require_school_admin
    redirect_to new_user_session_path if current_user.try(:school_admin) != true
  end

  def after_sign_in_path_for(resource)
    if current_user.try(:teacher)
      session[:previous_url] || teacher_homeworks_path
    else
      session[:previous_url] || user_questions_path
    end
  end

  def user_sign_in?
    current_user.present?
  end

  def user_teacher?
    current_user.try(:teacher)
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_500
    raise '500 exception'
  end
end
