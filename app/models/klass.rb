# encoding: utf-8
class Klass
  include Mongoid::Document
  include Mongoid::Timestamps

  field :default, type: Boolean, default: false
  field :name, type: String

  belongs_to :teacher, class_name: "User", inverse_of: :classes
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :klasses

end
