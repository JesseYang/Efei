# encoding: utf-8
require 'httparty'
require 'rqrcode_png'
require 'open-uri'
require 'string'
class Demo
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: Array, default: []
  field :order, type: Integer
  field :items, type: Array, default: []
  field :figure, type: String

end
