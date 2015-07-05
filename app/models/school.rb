# encoding: utf-8
require 'httparty'
class School
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :nickname, type: String, default: ""
  field :address_code, type: Integer
  field :detail_address, type: String
  field :for_test, type: Boolean, default: false
  has_many :teachers, class_name: "User", inverse_of: :school
  has_many :classes, class_name: "Klass", inverse_of: :school

end
