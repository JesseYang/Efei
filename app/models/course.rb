# encoding: utf-8
class Course
  include Mongoid::Document
  include Mongoid::Timestamps

  field :subject, type: Integer
  field :name, type: String
  field :start_at, type: Integer
  field :end_at, type: Integer
  field :grade, type: String
  field :desc, type: String
  field :suggestion, type: String
  field :textbook_url, type: String
  field :lesson_id_ary, type: Array

  field :ready, type: Boolean, default: false

  belongs_to :teacher, class_name: "User", inverse_of: :courses

end
