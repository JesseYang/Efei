# encoding: utf-8
class Study
  include Mongoid::Document
  include Mongoid::Timestamps

  field :course_id, type: String
  field :lesson_id, type: String
  field :video_id, type: String
  field :time, type: Integer
  field :is_last, type: Boolean, default: false

  belongs_to :student, class_name: "User", inverse_of: :studies

end
