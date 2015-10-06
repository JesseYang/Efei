# encoding: utf-8
class Client::UsersController < Client::ApplicationController
  layout :resolve_layout
  skip_before_filter :client_init, :only => [:pre_bind, :bind, :expire, :post_bind]

  def pre_bind
  end

  def bind_info
    @return_path = (params[:prev_link].present? ? params[:prev_link] : request.referrer) || main_page_client_users_path
    @title = "帐号绑定"
  end

  def password
    @return_path = params[:prev_link].present? ? params[:prev_link] : request.referrer
    @title = "修改密码"
  end

  def change_password
    value = @current_user.change_password(params[:cur_password], params[:new_password])
    value = { success: true } if value.nil?
    render json: value
  end

  def expire
  end

  def bind
    client_name = params[:client_name]
    client_password = params[:client_password]
    c = User.where(client_name: client_name, password: Encryption.encrypt_password(client_password)).first
    if c.blank?
      flash[:error] = "机构名称或者密码错误"
      redirect_to action: :pre_bind and return
    end
    url = Weixin.generate_authorize_link(Rails.application.config.server_host + "/client/users/#{c.id.to_s}/post_bind", true)
    redirect_to url and return
  end

  def post_bind
    c = User.where(id: params[:id]).first
    if c.blank?
      flash[:error] = "机构名称或者密码错误"
      redirect_to action: :bind and return
    end
    # get the weixin open id and user info
    info = Weixin.get_oauth_open_id_and_user_info(params[:code])
    # create the bind
    WeixinBind.create_client_bind(c, info)
    cookies[:client_open_id] = {
      :value => info[:open_id],
      :expires => 24.months.from_now,
      :domain => :all
    }
    redirect_to action: :bind_info and return
  end

  def unbind
    @weixin_bind = WeixinBind.where(id: params[:id]).first
    @weixin_bind.destroy if @weixin_bind.present?
  end

  def main_page
    @title = @current_user.client_name
  end

  def resolve_layout
    if %w{expire pre_bind unbind} .include? action_name
      "layouts/application"
    else
      "layouts/client"
    end
  end
end
