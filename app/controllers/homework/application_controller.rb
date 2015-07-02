require 'digest/sha1'
class Homework::ApplicationController < ApplicationController
  layout 'layouts/platform_homework'

  # for efei homework teachers

  before_filter :homework_init

  def homework_init
    ##### for test in local server #####
    # @current_user = User.where(homework: true).first
    # return
    ####################################

    if params[:code].present?
      # may come from weixin authorize, try to get the weixin user id
      @open_id = Platform.get_oauth_open_id(params[:code])
      if @open_id.present?
        @platform_bind = PlatformBind.find_teacher_by_open_id(@open_id)
        if @platform_bind.present?
          @current_user = @platform_bind.teacher
          cookies[:teacher_open_id] = {
            :value => @open_id,
            :expires => 24.months.from_now,
            :domain => :all
          }
        else
          # the weixin user has not bound to a homework teacher, clear current user and cookie
          @current_user = nil
          cookies.delete(:teacher_open_id, :domain => :all)
          # ask the user to bind
          redirect_to controller: "homework/users", action: :pre_bind and return
        end
      end
    end
    # try to find user by open id in cookie
    @open_id = cookies[:teacher_open_id]
    @platform_bind = PlatformBind.find_teacher_by_open_id(@open_id)
    if @platform_bind.present?
      @current_user = @platform_bind.teacher
    else
      # the open id in the cookies is wrong or expires
      @current_user = nil
      cookies.delete(:teacher_open_id, :domain => :all)
      # ask the user to quit
      redirect_to controller: "homework/users", action: :expire and return
    end
  end
end
