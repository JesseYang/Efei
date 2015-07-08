# encoding: utf-8
class Homework::UsersController < Homework::ApplicationController
  layout :resolve_layout
  skip_before_filter :homework_init, :only => [:pre_bind, :bind, :expire, :post_bind]

  def pre_bind
  end

  def bind_info
    @return_path = request.referrer
    @title = "帐号绑定"
  end

  def expire
  end

  def bind
    teacher_name = params[:teacher_name]
    teacher_auth_code = params[:teacher_auth_code]
    t = User.where(name: teacher_name, auth_code: teacher_auth_code).first
    if t.blank?
      flash[:error] = "姓名或者授权码不正确"
      redirect_to action: :pre_bind and return
    end
    url = Platform.generate_authorize_link(Rails.application.config.server_host + "/homework/users/#{t.id.to_s}/post_bind", true)
    redirect_to url and return
  end

  def post_bind
    t = User.where(id: params[:id]).first
    if t.blank?
      flash[:error] = "姓名或者授权码不正确"
      redirect_to action: :bind and return
    end
    # get the weixin open id and user info
    info = Platform.get_oauth_open_id_and_user_info(params[:code])
    # create the bind
    PlatformBind.create_teacher_bind(t, info)
    cookies[:teacher_open_id] = {
      :value => info[:open_id],
      :expires => 24.months.from_now,
      :domain => :all
    }
    if t.classes.blank?
      redirect_to controller: "homework/klasses", action: :list and return
    else
      redirect_to action: :bind_info and return
    end
  end

  def unbind
    @platform_bind = PlatformBind.where(id: params[:id]).first
    @platform_bind.destroy if @paltform_bind.present?
  end

  def resolve_layout
    if %w{expire pre_bind unbind bind_info} .include? action_name
      "layouts/application"
    else
      "layouts/platform_homework"
    end
  end
end
