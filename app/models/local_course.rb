# encoding: utf-8
class LocalCourse
  include Mongoid::Document
  include Mongoid::Timestamps

  field :city, type: String
  field :location, type: String
  field :time_desc, type: String
  field :time_ary, type: Array, default: [ ]
  field :number, type: String

  belongs_to :course, class_name: "Course", inverse_of: :local_courses
  belongs_to :coach, class_name: "User", inverse_of: :local_courses
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :student_local_courses
  has_many :study_reports, class_name: "StudyReport", inverse_of: :local_course

  def self.filter(subject, type)
    if subject != 0
      courses = Course.where(subject: subject)
    else
      courses = Course.all
    end
    if type != 0
      courses = courses.where(course_type: type)
    end
    courses.map { |e| e.local_courses} .flatten
  end

  def self.local_courses_for_select(student)
      hash = { "请选择" => -1 }
      LocalCourse.where(city: student.city).each do |lc|
        hash[lc.name + "(#{lc.number})"] = lc.id.to_s
      end
      hash
  end

  def desc
    self.name + "\n" + "教师：" + (self.coach.nil? ? "未分配" : self.coach.name) + "\n" + self.location
  end

  def time_ary_text
    text_ary = self.time_ary.map do |ele|
      start_time = Time.at(ele["start_time"]).strftime("%Y-%m-%d %H:%M")
      end_time = Time.at(ele["end_time"]).strftime("%Y-%m-%d %H:%M")
      start_time + " --- " + end_time
    end
    text_ary.join("\n")
  end

  def self.create_local_course(local_course)
    lc = LocalCourse.create({
      course_id: local_course["course_id"],
      coach_id: local_course["coach_id"],
      city: local_course["city"],
      location: local_course["location"],
      time_desc: local_course["time_desc"],
      number: local_course["number"]
    })
    lc.update_time_ary(local_course["time_ary"])
    true
  end

  def update_local_course(local_course)
    self.update_attributes({
      course_id: local_course["course_id"],
      coach_id: local_course["coach_id"],
      city: local_course["city"],
      location: local_course["location"],
      time_desc: local_course["time_desc"],
      number: local_course["number"]
    })
    self.update_time_ary(local_course["time_ary"])
    true
  end

  def update_time_ary(ary_text)
    text_ary = ary_text.split("\n")
    time_ary = [ ]
    text_ary.each do |ele|
      time_ele = { }
      start_time = ele.split('---')[0].strip
      end_time = ele.split('---')[1].strip
      time_ele["date"] = start_time.split(" ")[0]
      year, month, day = *(time_ele["date"].split("-"))
      start_hour, start_minute = start_time.split(" ")[1].split(":")
      end_hour, end_minute = end_time.split(" ")[1].split(":")
      time_ele["start_time"] = Time.mktime(year, month, day, start_hour, start_minute).to_i
      time_ele["end_time"] = Time.mktime(year, month, day, end_hour, end_minute).to_i
      time_ary << time_ele
    end
    self.time_ary = time_ary
    self.save
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
