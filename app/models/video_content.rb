# encoding: utf-8
require 'string'
class VideoContent
  extend CarrierWave::Mount
  mount_uploader :video, VideoUploader
end
