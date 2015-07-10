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
end
