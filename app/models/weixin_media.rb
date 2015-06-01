# encoding: utf-8
require 'rmagick'
require 'httparty'
class WeixinMedia
  include HTTParty
  base_uri "https://file.api.weixin.qq.com"
  format  :json

  include Mongoid::Document
  include Mongoid::Timestamps

  @@save_folder = "public/weixin_media/"

  field :server_id, type: String, default: ""
  field :file_type, type: String, default: ""
  field :error_code, type: String, default: ""
  field :dowloaded, type: Boolean, default: false


  def self.download_media(media_id, rotate=0)
    m = WeixinMedia.create(server_id: media_id)
    url = "/cgi-bin/media/get?access_token=#{Weixin.get_access_token}&media_id=#{media_id}"
    response = Weixin.get(url)
    if response.response.code != "200"
      m.error_code = "http_#{response.response.code}"
      m.save
      return m.id.to_s
    end
    case response.headers["content-type"]
    when "text/plain"
      # an error message
      m.error_code = JSON.parse(response.body)["errcode"]
      m.save
      return m.id.to_s
    when "image/jpeg"
      m.file_type = "jpg"
      file = File.open(@@save_folder + m.id.to_s, 'wb')
      file.write(response.body)
      m.save
      return m.id.to_s
    end
  end

  def self.update_rotate(media_id, rotate)
    media = WeixinMedia.where(server_id: media_id).first
    img = Magick::ImageList.new(@@save_folder + media.id.to_s + "." + media.file_type)
    img.rotate!(rotate)
    img.write(@@save_folder + media.id.to_s)
  end
end
