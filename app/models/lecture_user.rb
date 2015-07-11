# encoding: utf-8
class LectureUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :mobile, type: String, default: ""

end
