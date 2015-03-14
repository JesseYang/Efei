# encoding: utf-8
class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String, default: ""

  belongs_to :user
  belongs_to :question

end
