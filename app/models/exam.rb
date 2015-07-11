# encoding: utf-8
class Exam
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :type, type: String
  field :subject, type: Integer

  belongs_to :teacher, class_name: "User", inverse_of: :exams
  belongs_to :klass, class_name: "Klass", inverse_of: :exams

  has_many :scores

  def lack_students
    students = [ ]
    self.klass.students.each do |ele|
      if self.scores.where(student_id: ele.id.to_s).blank?
        students << ele
      end
    end
    students
  end

  def submit_rate
    submit_number = self.scores.count
    total_number = self.klass.students.length
    total_number == 0 ? "0" : ((submit_number * 1.0 / total_number) * 100).round.to_s + "%"
  end

  def submit_summary
    submit_number = self.scores.count
    total_number = self.klass.students.length
    "#{submit_number}/#{total_number}"
  end

  def categories_str
    case self.type
    when "abcd"
      "A,B,C,D,未提交"
    when "100"
      "90-100,80-90,70-80,60-70,不及格"
    else
      ""
    end
  end

  def data_str
    case self.type
    when "abcd"
      data_ary = [0, 0, 0, 0]
      score_ary = self.scores.map { |e| e.score }
      data_ary[0] = score_ary.select { |e| e == 100 } .length
      data_ary[1] = score_ary.select { |e| e == 80 } .length
      data_ary[2] = score_ary.select { |e| e == 60 } .length
      data_ary[3] = score_ary.select { |e| e == 40 } .length
      data_ary << self.lack_students.length
      data_ary.join(',')
    else
      data_ary = [0, 0, 0, 0, 0]
      score_ary = self.scores.map { |e| e.score }
      data_ary[0] = score_ary.select { |e| e >= 90 } .length
      data_ary[1] = score_ary.select { |e| e >= 80 && e < 90 } .length
      data_ary[2] = score_ary.select { |e| e >= 70 && e < 80 } .length
      data_ary[3] = score_ary.select { |e| e >= 60 && e < 70 } .length
      data_ary[4] = score_ary.select { |e| e < 60 } .length
      data_ary << self.lack_students.length
      data_ary.join(',')
    end
  end
end
