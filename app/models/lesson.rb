# encoding: utf-8
class Lesson
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :video_id_ary, type: Array, default: []
  field :exercise_page, type: Integer, default: -1
  belongs_to :course, class_name: "Course", inverse_of: :lessons
  has_many :videos, class_name: "Video", inverse_of: :lesson
  has_one :homework, class_name: "Homework", inverse_of: :lesson

  has_many :learn_logs
  has_many :action_logs

  def name_with_course_and_teacher
    course_name = self.course.present? ? self.course.name_with_teacher : "（未绑定课程）"

    course_name + " " + self.name
  end

  def touch_parents
    self.course.try(:touch)
  end

  def order
    if self.course.blank?
      return "未绑定"
    else
      index = self.course.lesson_id_ary.index(self.id.to_s)
      if index == -1
        return "未指定序号"
      else
        return "第#{index+1}讲"
      end
    end
  end

  def info_for_tablet(course, order)
    {
      server_id: self.id.to_s,
      course_id: course.id.to_s,
      name: self.name,
      lesson_order: order,
      exercise_page: self.exercise_page,
      update_at: self.updated_at.to_s
    }
  end
end
