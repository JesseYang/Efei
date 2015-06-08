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

  def self.create_new(content, student, local_course)
    new_content = [ ]
    content.each do |ele|
      new_ele = {
        type: ele["type"]
      }
      if ele["type"] == "image"
        media = WeixinMedia.download_media(ele["value"], ele["rotate"])
        new_ele[:value] = media.id.to_s
        new_ele[:file_type] = media.file_type.to_s
      else
        new_ele[:value] = ele["value"]
      end
      new_content[ele["index"].to_i] = new_ele
    end
    sr = StudyReport.create(content: new_content)
    sr.student = student
    sr.local_course = local_course
    sr.coach = local_course.coach
    sr.save
    sr.id.to_s
  end

  def update_existing(content)
    new_content = [ ]
    content.each do |ele|
      new_ele = {
        type: ele["type"]
      }
      if ele["type"] == "image" && ele["image_type"] == "new"
        media = WeixinMedia.download_media(ele["value"], ele["rotate"])
        new_ele[:value] = media.id.to_s
        new_ele[:file_type] = media.file_type.to_s
      elsif ele["type"] == "image" && ele["image_type"] == "existing"
        media = WeixinMedia.update_rotate(ele["value"], ele["rotate"])
        new_ele[:value] = media.id.to_s
        new_ele[:file_type] = media.file_type.to_s
      else
        new_ele[:value] = ele["value"]
      end
      new_content[ele["index"].to_i] = new_ele
    end
    self.content = new_content
    self.save
  end

  def submit
    self.finished_at = Time.now.to_i
    self.finish = true
    self.save
  end

  def month
    Time.at(self.finished_at || self.updated_at).strftime("%m") + "月"
  end

  def day
    Time.at(self.finished_at || self.updated_at).strftime("%d") + "日"
  end

  def content_in_short
    str = content.select { |e| e["type"] == "text" } .map { |e| e["value"] } .join
    str[0..[str.length, 80].min]
  end

  def info
    Time.at(self.finished_at || self.updated_at).strftime("%Y.%m.%d") + " 教师：" + self.coach.name
  end

  def title
    self.local_course.course.name + "，#{Time.at(self.finished_at).strftime("%Y.%m.%d")}，#{self.coach.name}"
  end

end
