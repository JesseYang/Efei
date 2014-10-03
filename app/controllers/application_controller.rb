# encoding: utf-8
require 'string'
require 'array'
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'layouts/student'

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
        request.fullpath != "/users" &&
        request.fullpath != "/" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    else
      session[:previous_url] = nil
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

  def require_student
    if current_user.try(:school_admin) == true || current_user.try(:teacher) == true
      sign_out(current_user)
      flash[:notice] = "请以学生身份登录"
      redirect_to new_user_session_path
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
    if current_user.try(:school_admin)
      session[:previous_url] || school_admin_teachers_path
    elsif current_user.try(:teacher)
      session[:previous_url] || teacher_homeworks_path
    else
      session[:previous_url] || student_notes_path
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

  def page
    params[:page].to_i == 0 ? 1 : params[:page].to_i
  end

  def per_page
    params[:per_page].to_i == 0 ? 10 : params[:per_page].to_i
  end

  def auto_paginate(value, count = nil)
    retval = {}
    retval["current_page"] = page
    retval["per_page"] = per_page
    retval["previous_page"] = (page - 1 > 0 ? page - 1 : 1)
    # retval["previous_page"] = [page - 1, 1].max

    # 当没有block或者传入的是一个mongoid集合对象时就自动分页
    # TODO : 更优的判断是否mongoid对象?
    # instance_of?(Mongoid::Criteria) .by lcm
    # if block_given? 
    # if value.methods.include? :page
    if value.instance_of?(Mongoid::Criteria)
      count ||= value.count
      value = value.page(retval["current_page"]).per(retval["per_page"])
    elsif value.is_a?(Array) && value.count > per_page
      count ||= value.count
      value = value.slice((page - 1) * per_page, per_page)
    end
      
    if block_given?
      retval["data"] = yield(value) 
    else
      retval["data"] = value
    end
    retval["total_page"] = ( (count || value.count )/ per_page.to_f ).ceil
    retval["total_page"] = retval["total_page"] == 0 ? 1 : retval["total_page"]
    retval["total_number"] = count || value.count
    retval["next_page"] = (page+1 <= retval["total_page"] ? page+1: retval["total_page"])
    retval
  end
end
