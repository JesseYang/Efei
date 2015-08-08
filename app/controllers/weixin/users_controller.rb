# encoding: utf-8
class Weixin::UsersController < Weixin::ApplicationController
  layout :resolve_layout
  skip_before_filter :weixin_init, :only => [:pre_bind, :bind, :expire, :post_bind]

  def pre_bind
  end

  def bind_info
    @return_path = request.referrer
    @title = "帐号绑定"
  end

  def expire
    
  end

  def bind
    Rails.logger.info "AAAAAAAAAAAAA"
    Rails.logger.info params[:student_id]
    Rails.logger.info "AAAAAAAAAAAAA"
    s = User.where(id: params[:student_id]).first
    Rails.logger.info "AAAAAAAAAAAAA"
    Rails.logger.info s.inspect
    Rails.logger.info "AAAAAAAAAAAAA"
    if s.blank?
      render json: { success: false } and return
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
