# encoding: utf-8
class Lesson
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :video_id_ary, type: Array

end
