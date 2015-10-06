# encoding: utf-8
class Weixin::UsersController < Weixin::ApplicationController
  layout :resolve_layout
  skip_before_filter :weixin_init, :only => [:pre_bind, :bind, :expire, :post_bind]

  def pre_bind
  end

  def bind_info
    @return_path = (params[:prev_link].present? ? params[:prev_link] : request.referrer) || weixin_courses_path
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
    if params[:student_id].present?
      s = User.where(id: params[:student_id]).first
      if s.blank?
        render json: { success: false } and return
      end
    else
      s = User.find_by_email_mobile(params[:email_mobile])
      if s.blank? || s.password != Encryption.encrypt_password(params[:password])
        render json: { success: false } and return
      end
    end
    url = Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/users/#{s.id.to_s}/post_bind", true)
    render json: { success: true, url: url } and return
  end

  def post_bind
    s = User.where(id: params[:id]).first
    if s.blank?
      flash[:error] = "学员号不正确"
      redirect_to action: :bind and return
    end
    # get the weixin open id and user info
    info = Weixin.get_oauth_open_id_and_user_info(params[:code])
    # create the bind
    WeixinBind.create_student_bind(s, info)
    cookies[:student_open_id] = {
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
      "layouts/weixin"
    end
  end
end
