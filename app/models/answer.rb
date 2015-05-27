# encoding: utf-8
class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :finish, type: Boolean, default: false
  field :answer_content, type: Hash, default: { }

  belongs_to :homework, class_name: "Homework", inverse_of: :answers
  belongs_to :student, class_name: "User", inverse_of: :student_answers
  belongs_to :coach, class_name: "User", inverse_of: :coach_answers

end
