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
end
