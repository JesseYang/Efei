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

  def signature
    @jsapi_ticket = Weixin.get_jsapi_ticket
    @noncestr = rand(36**10).to_s 36
    @timestamp = Time.now.to_i
    @url = params[:url]
    string = "jsapi_ticket=#{@jsapi_ticket}&noncestr=#{@noncestr}&timestamp=#{@timestamp}&url=#{@url}"
    @signature = Digest::SHA1.hexdigest(string)
    retval = {
      success: true,
      data: {
        signature: @signature,
        noncestr: @noncestr,
        timestamp: @timestamp,
        appid: Weixin::APPID,
        jsapi_ticket: @jsapi_ticket
      }
    }
    render json: retval and return
  end
end
