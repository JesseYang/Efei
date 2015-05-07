# encoding: utf-8
require 'string'
class Avatar
  extend CarrierWave::Mount
  mount_uploader :avatar, AvatarUploader

end
