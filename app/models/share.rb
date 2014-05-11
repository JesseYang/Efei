# encoding: utf-8
class Share
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  belongs_to :homework

end
