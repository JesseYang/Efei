# encoding: utf-8
module UserComponents::Coach
  extend ActiveSupport::Concern

  included do
    field :coach, type: Boolean, default: false

    has_many :local_courses, class_name: "LocalCourse", inverse_of: :coach
    has_many :coach_answers, class_name: "Answer", inverse_of: :coach
    has_many :study_reports, class_name: "StudyReport", inverse_of: :coach

  end

  module ClassMethods
  end
end