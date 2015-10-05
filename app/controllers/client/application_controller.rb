require 'digest/sha1'
class Client::ApplicationController < ApplicationController
  layout 'layouts/client'

  before_filter :client_init

  def client_init
    ##### for test in local server #####
    # @current_user = User.where(is_client: true).first
    # return
    ####################################

    if params[:code].present?
      # may come from weixin authorize, try to get the weixin user id
      @open_id = Weixin.get_oauth_open_id(params[:code])
      if @open_id.present?
        @weixin_bind = WeixinBind.find_client_by_open_id(@open_id)
        if @weixin_bind.present?
          @current_user = @weixin_bind.client
          cookies[:client_open_id] = {
            :value => @open_id,
            :expires => 24.months.from_now,
            :domain => :all
          }
        else
          # the weixin user has not bound to a client, clear current user and cookie
          @current_user = nil
          cookies.delete(:client_open_id, :domain => :all)
          # ask the user to bind
          redirect_to controller: "client/users", action: :pre_bind and return
        end
      end
    end
    # try to find user by open id in cookie
    @open_id = cookies[:client_open_id]
    @weixin_bind = WeixinBind.find_client_by_open_id(@open_id)
    if @weixin_bind.present?
      @current_user = @weixin_bind.client
    else
      # the open id in the cookies is wrong or expires
      @current_user = nil
      cookies.delete(:client_open_id, :domain => :all)
      # ask the user to quit
      redirect_to controller: "client/users", action: :expire and return
    end
  end

  def render_with_auth_key(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value
  end
end
