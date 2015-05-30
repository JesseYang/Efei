# encoding: utf-8
module UserComponents::Coach
  extend ActiveSupport::Concern

  included do
    field :coach, type: Boolean, default: false

    has_many :local_courses, class_name: "LocalCourse", inverse_of: :coach
    has_many :coach_answers, class_name: "Answer", inverse_of: :coach
    has_many :study_reports, class_name: "StudyReport", inverse_of: :coach

    has_many :coach_weixin_bind, class_name: "WeixinBind", inverse_of: :coach

  end

  module ClassMethods
  end

  def current_students
    # those courses are not stopeed or has stopped within 10 days, are current courses
    current_local_courses = self.local_courses.select do |lc|
      lc.course.end_at > Time.now.to_i - 10.days.to_i
    end
    students = current_local_courses.map { |e| e.students } .flatten .uniq
  end
end