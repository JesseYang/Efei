class Platform::ApplicationController < ApplicationController
  layout 'layouts/homework'

  # for parents

  skip_before_filter :init
  before_filter :platform_init

  def platform_init
    ##### for test in local server #####
    @current_user = User.where(email: 'stu@test.com').first
    return
    ####################################

    if params[:code].present?
      # may come from weixin authorize, try to get the weixin user id
      @open_id = Platform.get_oauth_open_id(params[:code])
      if @open_id.present?
        @platform_bind = PlatformBind.find_parent_by_open_id(@open_id)
        if @platform_bind.present?
          @current_user = @platform_bind.parent
          cookies[:platform_open_id] = {
            :value => @open_id,
            :expires => 24.months.from_now,
            :domain => :all
          }
        else
          # the weixin user has not bound to a student, clear current user and cookie
          @current_user = nil
          cookies.delete(:student_open_id, :domain => :all)
          # ask the user to bind
          redirect_to controller: "platform/users", action: :pre_bind and return
        end
      end
    end
    # try to find user by open id in cookie
    @open_id = cookies[:student_open_id]
    @platform_bind = PlatformBind.find_parent_by_open_id(@open_id)
    if @platform_bind.present?
      @current_user = @platform_bind.parent
    else
      # the open id in the cookies is wrong or expires
      @current_user = nil
      cookies.delete(:student_open_id, :domain => :all)
      # ask the user to quit
      redirect_to controller: "platform/users", action: :expire and return
    end
  end
end
