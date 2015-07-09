# encoding: utf-8
class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String
  field :score, type: Integer

  belongs_to :exam
  belongs_to :student, class_name: "User", inverse_of: :scores
end
