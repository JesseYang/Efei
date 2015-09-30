# encoding: utf-8
require 'string'
class SnapshotImage
  extend CarrierWave::Mount
  mount_uploader :snapshot_image, SnapshotImageUploader
end
