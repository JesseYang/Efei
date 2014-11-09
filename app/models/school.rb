# encoding: utf-8
require 'httparty'
class School
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :address_code, type: Integer
  field :detail_address, type: String
  has_many :teachers, class_name: "User", inverse_of: :school

end
