# encoding: utf-8
class TecentNews
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String, default: ""
  field :url, type: String, default: ""
  # 0 for policy, 1 for course info
  field :type, type: Integer, default: -1

end
