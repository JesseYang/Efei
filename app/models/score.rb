# encoding: utf-8
class Score
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type, type: String
  field :score, type: Integer

  belongs_to :exam
  belongs_to :student, class_name: "User", inverse_of: :scores

  def update_score(score)
    self.update_attribute(:score, score.to_i)
  end

  def score_in_text
    if type == "abcd"
      case score
      when 100
        "A"
      when 80
        "B"
      when 60
        "C"
      when 40
        "D"
      end
    elsif type == "100"
      score.to_s
    end
  end
end
