# encoding: utf-8
class TabletAnswer
  include Mongoid::Document
  include Mongoid::Timestamps

  # key is question id value, value is a hasn which has two keys:
  # => answer
  # => duration
  field :answer_content, type: Hash, default: { }

  belongs_to :exercise, class_name: "Homework", inverse_of: :tablet_answers
  belongs_to :student, class_name: "User", inverse_of: :student_answers

end
