# encoding: utf-8
require 'string'
class WeixinNewsMedia
  extend CarrierWave::Mount
  mount_uploader :weixin_news_media, WeixinNewsMediaUploader

end
