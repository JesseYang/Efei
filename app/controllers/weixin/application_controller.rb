class Weixin::ApplicationController < ApplicationController
  layout 'layouts/weixin'

  before_filter :weixin_init

  def weixin_init
  	@current_user = User.where(email: 'zhangsan@test.com').first
  end

  def render_with_auth_key(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value
  end
end
