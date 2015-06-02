# encoding: utf-8
class StudyReport
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :content, type: Array, default: []
  field :finish, type: Boolean, default: false
  field :finished_at, type: Integer

  belongs_to :local_course, class_name: "LocalCourse", inverse_of: :study_reports
  belongs_to :student, class_name: "User", inverse_of: :student_study_reports
  belongs_to :coach, class_name: "User", inverse_of: :study_reports

  def month
    Time.at(self.finished_at).strftime("%m") + "月"
  end

  def day
    Time.at(self.finished_at).strftime("%d") + "日"
  end

  def content_in_short
    str = content.select { |e| e["type"] == "text" } .map { |e| e["value"] } .join
    str[0..[str.length, 80].min]
  end

  def info
    Time.at(self.finished_at).strftime("%Y.%m.%d") + " 教师：" + self.coach.name
  end

  def title
    self.local_course.course.name + "，#{Time.at(self.finished_at).strftime("%Y.%m.%d")}，#{self.coach.name}"
  end

end
