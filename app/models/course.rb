# encoding: utf-8
class Course
  include Mongoid::Document
  include Mongoid::Timestamps

  field :subject, type: Integer
  field :name, type: String
  field :start_at, type: Integer
  field :end_at, type: Integer
  field :grade, type: String
  field :desc, type: String
  field :suggestion, type: String
  field :textbook_url, type: String
  field :lesson_id_ary, type: Array, default: [ ]

  # 1 for long course, 2 for module course
  field :course_type, type: Integer, default: 1

  field :ready, type: Boolean, default: false

  has_and_belongs_to_many :students, class_name: "User", inverse_of: :student_courses

  has_many :lessons, class_name: "Lesson", inverse_of: :course
  belongs_to :teacher, class_name: "User", inverse_of: :courses

  has_many :action_logs


  def self.filter(subject, type)
    if subject != 0
      courses = Course.where(subject: subject)
    else
      courses = Course.all
    end
    if type != 0
      courses = courses.where(course_type: type)
    end
    courses
  end

  def name_with_teacher
    "《" + self.name + "》" + "(教师：" + self.teacher.name + ")"
  end

  def has_lesson?
    self.lesson_id_ary.each do |e|
      if e.present?
        return true
      end
    end
    return false
  end

  def self.type_for_select
    hash = { "学期课" => 1, "模块课" => 2 }
  end

  def type_text
    self.course_type == 1 ? "学期课" : "模块课"
  end

  def self.type_for_select_with_all
    hash = { "全部" => 0, "学期课" => 1, "模块课" => 2 }
  end

  def self.courses_for_select
    hash = { "请选择" => -1 }
    Course.all.each do |c|
      hash[c.name_with_teacher] = c.id.to_s
    end
    hash
  end

  def info_for_tablet
    {
      server_id: self.id.to_s,
      teacher_id: self.teacher.id.to_s,
      subject: self.subject.to_i,
      name: self.name,
      start_at: self.start_at,
      end_at: self.end_at,
      grade: self.grade,
      desc: self.desc,
      suggestion: self.suggestion,
      textbook_url: self.textbook_url,
      update_at: self.updated_at.to_s
    }
  end

  def teacher_name
    "张三"
  end

  def coach_name
    "李四"
  end
end
