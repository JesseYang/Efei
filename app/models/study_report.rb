# encoding: utf-8
class StudyReport
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :content, type: Array, default: []

  belongs_to :local_course, class_name: "LocalCourse", inverse_of: :study_reports
  belongs_to :student, class_name: "User", inverse_of: :student_study_reports
  belongs_to :coach, class_name: "User", inverse_of: :study_reports

end
