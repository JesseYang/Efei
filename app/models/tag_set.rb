# encoding: utf-8
class TagSet
  include Mongoid::Document
  include Mongoid::Timestamps
  field :tags, type: Array, default: []
  field :subject, type: Integer
  field :default, type: Boolean, default: false
  belongs_to :teacher, class_name: "User", inverse_of: :tag_sets

end
