# encoding: utf-8
class Coach::UsersController < Coach::ApplicationController
  layout :resolve_layout
  skip_before_filter :coach_init, :only => [:pre_bind, :bind, :expire, :post_bind]

  def pre_bind
  end

  def bind_info
    @return_path = (params[:prev_link].present? ? params[:prev_link] : request.referrer) || coach_students_path
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
    if params[:coach_id].present?
      c = User.where(id: params[:coach_id]).first
      if c.blank?
        render json: { success: false } and return
      else
        url = Weixin.generate_authorize_link(Rails.application.config.server_host + "/coach/users/#{c.id.to_s}/post_bind", true)
        render json: { success: true, url: url } and return
      end
    else
      coach_number = params[:coach_number]
      coach_password = params[:coach_password]
      client = User.where(client_name: params[:coach_client_name]).first
      if client.blank?
        flash[:error] = "机构不存在"
        redirect_to action: :pre_bind and return
      end
      c = client.client_coaches.where(coach_number: coach_number, password: Encryption.encrypt_password(coach_password)).first
      if c.blank?
        flash[:error] = "教师工号或者密码不正确"
        redirect_to action: :pre_bind and return
      end
      url = Weixin.generate_authorize_link(Rails.application.config.server_host + "/coach/users/#{c.id.to_s}/post_bind", true)
      redirect_to url and return
    end
  end

  def post_bind
    c = User.where(id: params[:id]).first
    if c.blank?
      flash[:error] = "员工号或者密码不正确"
      redirect_to action: :bind and return
    end
    # get the weixin open id and user info
    info = Weixin.get_oauth_open_id_and_user_info(params[:code])
    # create the bind
    WeixinBind.create_coach_bind(c, info)
    cookies[:coach_open_id] = {
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

  def resolve_layout
    if %w{expire pre_bind unbind} .include? action_name
      "layouts/application"
    else
      "layouts/coach"
    end
  end
end
