require 'digest/sha1'
class Coach::ApplicationController < ApplicationController
  layout 'layouts/coach'

  before_filter :coach_init

  def coach_init
    @current_user = User.where(coach: true).first
  end

  def render_with_auth_key(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value
  end
end
