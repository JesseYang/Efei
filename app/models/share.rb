# encoding: utf-8
class Share
  include Mongoid::Document
  include Mongoid::Timestamps
  # 1 for read only, 2 for editable
  field :permission, type: Integer
  belongs_to :user
  belongs_to :homework

end
