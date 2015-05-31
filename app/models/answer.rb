# encoding: utf-8
class Answer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :finish, type: Boolean, default: false
  # each value in the answer_content has the following keys:
  # => item_index: only for choice answer
  # => content: array, element of which is hash, can be text or images
  # => comment: array, element of which is hash, can be text of images
  field :answer_content, type: Hash, default: { }

  belongs_to :homework, class_name: "Homework", inverse_of: :answers
  belongs_to :student, class_name: "User", inverse_of: :student_answers
  belongs_to :coach, class_name: "User", inverse_of: :coach_answers

end
