# encoding: utf-8
require 'string'
class MaterialImage
  extend CarrierWave::Mount
  mount_uploader :material_image, MaterialImageUploader

end
