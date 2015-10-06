class Weixin::ApplicationController < ApplicationController
  layout 'layouts/weixin'

  skip_before_filter :init
  before_filter :weixin_init

  def weixin_init
    ##### for test in local server #####
    @current_user = User.where(mobile: '13000001111').first
    return
    ####################################

    if params[:code].present?
      # may come from weixin authorize, try to get the weixin user id
      @open_id = Weixin.get_oauth_open_id(params[:code])
      if @open_id.present?
        @weixin_bind = WeixinBind.find_student_by_open_id(@open_id)
        if @weixin_bind.present?
          @current_user = @weixin_bind.student
          cookies[:student_open_id] = {
            :value => @open_id,
            :expires => 24.months.from_now,
            :domain => :all
          }
        else
          # the weixin user has not bound to a student, clear current user and cookie
          @current_user = nil
          cookies.delete(:student_open_id, :domain => :all)
          # ask the user to bind
          redirect_to controller: "weixin/users", action: :pre_bind and return
        end
      end
    end
    # try to find user by open id in cookie
    @open_id = cookies[:student_open_id]
    @weixin_bind = WeixinBind.find_student_by_open_id(@open_id)
    if @weixin_bind.present?
      if @weixin_bind.student.blank?
        @weixin_bind.destroy
      else
        @current_user = @weixin_bind.student
        return
      end
    end
    # the open id in the cookies is wrong or expires
    @current_user = nil
    cookies.delete(:student_open_id, :domain => :all)
    # ask the user to quit
    redirect_to controller: "weixin/users", action: :expire and return
  end

  def render_with_auth_key(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value
  end
end
