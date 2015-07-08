# encoding: utf-8
class Exam
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String
  field :subject, type: Integer

  belongs_to :teacher, class_name: "User", inverse_of: :exams
  belongs_to :klass, class_name: "Klass", inverse_of: :exams

end
