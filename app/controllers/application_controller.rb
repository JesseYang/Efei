# encoding: utf-8
require 'string'
require 'array'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  layout 'layouts/efei'

  attr_reader :current_user

  before_filter :set_flash
  before_filter :store_location
  before_filter :init

  helper_method :user_signed_in?, :current_user

  def init
    if params[:client].to_s.start_with?("android")
      @client = "android"
    elsif params[:client].to_s.start_with?("ios")
      @client = "ios"
    else
      @client = "browser"
    end
    refresh_session(params[:auth_key] || cookies[:auth_key])
  end

  def user_signed_in?
    current_user.present?
  end

  def refresh_session(auth_key)
    @current_user = auth_key.blank? ? nil : User.find_by_auth_key(auth_key)
    if !current_user.nil?
      # If current user is not empty, set cookie
      cookies[:auth_key] = {
        :value => auth_key,
        :expires => 24.months.from_now,
        :domain => :all
      }
      return true
    else
      # If current user is empty, delete cookie
      cookies.delete(:auth_key, :domain => :all)
      return false
    end
  end

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
    if current_user.blank? || current_user.try(:school_admin) == true || current_user.try(:teacher) == true
      refresh_session(nil)
      flash[:notice] = "请以学生身份登录"
      redirect_to new_account_session_path
    end
  end

  def require_teacher
    if current_user.try(:teacher) != true
      refresh_session(nil)
      flash[:notice] = "请以教师身份登录"
      redirect_to new_account_session_path
    end
  end

  def require_school_admin
    redirect_to new_account_session_path if current_user.try(:school_admin) != true
  end

  def require_admin
    redirect_to new_account_session_path if current_user.try(:admin) != true
  end

  def user_sign_in?
    current_user.present?
  end

  def user_teacher?
    current_user.try(:teacher)
  end

  def redirect_to_root(role = "teacher")
    if current_user.blank?
      "/redirect" + "?role=#{role}"
    elsif current_user.super_admin == true || (current_user.admin == true && current_user.permission > 0)
      current_user.default_admin_path
    elsif current_user.try(:teacher)
      teacher_nodes_path
    else
      student_notes_path
    end
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_500
    raise '500 exception'
  end

  def render_json(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    render json: value
  end

  def page
    params[:page].to_i == 0 ? 1 : params[:page].to_i
  end

  def per_page
    params[:per_page].to_i == 0 ? 10 : params[:per_page].to_i
  end

  def auto_paginate_ajax(value, page_ajax, per_page_ajax)
    page_ajax = page_ajax.to_i
    per_page_ajax = per_page_ajax.to_i
    retval = {}
    retval['current_page'] = page_ajax
    retval['per_page'] = per_page_ajax
    retval["previous_page"] = (page_ajax - 1 > 0 ? page_ajax - 1 : 1)

    count = value.count
    value = value.page(retval["current_page"]).per(retval["per_page"])
    retval["data"] = value

    retval["start_number"] = (retval["current_page"] - 1) * retval["per_page"]
    retval["end_number"] = retval["current_page"] * retval["per_page"]

    retval["total_page"] = ( count / per_page_ajax.to_f ).ceil
    retval["total_page"] = retval["total_page"] == 0 ? 1 : retval["total_page"]
    retval["total_number"] = count
    retval["next_page"] = (page_ajax + 1 <= retval["total_page"] ? page_ajax + 1: retval["total_page"])
    retval 
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

  def signature
    @jsapi_ticket = Weixin.get_jsapi_ticket
    @noncestr = rand(36**10).to_s 36
    @timestamp = Time.now.to_i
    @url = CGI::unescape(params[:url])
    string = "jsapi_ticket=#{@jsapi_ticket}&noncestr=#{@noncestr}&timestamp=#{@timestamp}&url=#{@url}"
    @signature = Digest::SHA1.hexdigest(string)
    retval = {
      success: true,
      data: {
        signature: @signature,
        noncestr: @noncestr,
        timestamp: @timestamp,
        appid: Weixin::APPID,
        string: string,
        jsapi_ticket: @jsapi_ticket
      }
    }
    render json: retval and return
  end
end
