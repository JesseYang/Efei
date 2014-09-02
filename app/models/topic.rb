# encoding: utf-8
class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :subject, type: Integer

  has_and_belongs_to_many :notes

end
