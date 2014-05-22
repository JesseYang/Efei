# encoding: utf-8
require 'httparty'
require 'string'
class Document
  extend CarrierWave::Mount
  mount_uploader :document, DocumentUploader

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  attr_accessor :name, :temp_name, :subject, :images

  # http://www.aspose.com/docs/display/wordsjava/ImageType
  NO_IMAGE = 0
  UNKNOWN = 1
  EMF = 2
  WMF = 3
  PICT = 4
  JPEG = 5
  PNG = 6
  BMP = 7

  def initialize(subject)
    case subject
    when Subject::MATH
      MathDocument.new
    when Subject::ENGLISH
      EnglishDocument.new
    else
      nil
    end
  end
end
