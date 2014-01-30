#encoding: utf-8
class Print
  include Mongoid::Document
  include Mongoid::Timestamps
  field :current, type: Boolean, default: true
  field :question_ids, type: Array, default: []
  belongs_to :user

end
