# encoding: utf-8
class LocalCourse
  include Mongoid::Document
  include Mongoid::Timestamps

  field :city, type: String

  belongs_to :course, class_name: "Course", inverse_of: :local_courses
  belongs_to :coach, class_name: "User", inverse_of: :local_courses
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :student_local_courses
  has_many :study_reports, class_name: "StudyReport", inverse_of: :local_course

  def name
  	self.course.name
  end

  def subject
  	self.course.subject
  end

  def teacher_name
  	self.course.teacher.name
  end

  def coach_name
  	self.coach.name
  end
end
