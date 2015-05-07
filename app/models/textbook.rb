# encoding: utf-8
require 'string'
class Textbook
  extend CarrierWave::Mount
  mount_uploader :textbook, TextbookUploader

end
