# encoding: utf-8
class Weixin::UsersController < Weixin::ApplicationController
  skip_before_filter :weixin_init, :only => [:pre_bind, :bind]

  def pre_bind
  end

  def show
  end

  def bind
    student_number = params[:student_number]
    s = User.where(student_number: student_number).first
    if s.blank?
      flash[:error] = "学员号不正确"
      redirect_to action: :pre_bind and return
    end
    url = Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/users/#{s.id.to_s}/post_bind", true)
    redirect_to url and return
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
    redirect_to action: :show and return
  end

  def unbind
    @weixin_bind = WeixinBind.where(id: params[:id]).first
    @weixin_bind.destroy if @weixin_bind.present?
  end
end
