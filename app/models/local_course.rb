# encoding: utf-8
class LocalCourse
  include Mongoid::Document
  include Mongoid::Timestamps

  field :city, type: String
  field :location, type: String
  field :time_desc, type: String
  field :time_ary, type: Array, default: [ ]

  belongs_to :course, class_name: "Course", inverse_of: :local_courses
  belongs_to :coach, class_name: "User", inverse_of: :local_courses
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :student_local_courses
  has_many :study_reports, class_name: "StudyReport", inverse_of: :local_course

  def desc
    self.name + "\n" + "教师：" + self.coach.name + "\n" + self.location
  end

  def time_ary_text
    ""
  end

  def self.create_local_course(local_course)
    lc = LocalCourse.create({
      course_id: local_course["course_id"],
      coach_id: local_course["coach_id"],
      city: local_course["city"],
      location: local_course["location"],
      time_desc: local_course["time_desc"]
    })
    true
  end

  def update_local_course(local_course)
    self.update_attributes({
      course_id: local_course["course_id"],
      coach_id: local_course["coach_id"],
      city: local_course["city"],
      location: local_course["location"],
      time_desc: local_course["time_desc"]
    })
    true
  end

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

  def push_time(start_time, end_time)
    ele = {
      date: start_time.strftime("%Y-%m-%d"),
      start_time: start_time.to_i,
      end_time: end_time.to_i
    }
    self.time_ary.push(ele)
    self.save
  end
end
