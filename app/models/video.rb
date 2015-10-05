# encoding: utf-8
require 'float'
require 'integer'
class Video
  include Mongoid::Document
  include Mongoid::Timestamps

  # 1 for knowledge, 2 for example, 3 for episode, 4 for question
  field :video_type, type: Integer
  field :name, type: String
  field :video_url, type: String

  # structure of one element in tags:
  # => tag_type: Integer, 1 for index, 2 for episode, 3 for example, 4 for summary
  # => time: Integer
  # => name: String, only for index tags
  # => episode_id: String, only for episode tags
  # => duration: Integer, only for example tags
  # => question_id: Array, only for example tags
  # => snapshot_id: String, only for summary tags
  field :tags, type: Array, default: []

  # for example videos, the question content
  field :content, type: Array, default: []
  # for example videos, recommended finish time
  field :time, type: Integer
  # for example videos, page
  field :page, type: Integer
  # for example videos, example name
  field :question_name, type: String

  belongs_to :lesson, class_name: "Lesson", inverse_of: :videos
  belongs_to :question, class_name: "Question", inverse_of: :question

  has_many :snapshots

  def touch_parents
    self.lesson.try(:touch)
    self.lesson.try(:touch_parents)
  end

  def order
    index = self.lesson.video_id_ary.index(self.id.to_s)
    if index == -1
      return "未指定序号"
    else
      return "第#{index+1}段"
    end
  end

  def snapshots_for_select
    hash = { "请选择" => -1 }
    self.snapshots.each do |s|
      hash[s.time.to_time] = s.id.to_s
    end
    hash
  end

  def episodes_for_select
    hash = { "请选择" => -1 }
    self.lesson.videos.where(video_type: 3).each do |v|
      hash[v.name] = v.id.to_s
    end
    hash
  end

  def self.existing_video_content_for_select
    hash = { "请选择" => -1 }
    Video.all.each do |v|
      next if v.lesson.blank?
      hash[v.course_name + ", " + v.lesson_name + ", " + v.name] = v.id.to_s
    end
    hash
  end

  def self.video_type_for_select
    {
      "请选择" => -1,
      "知识点" => 1,
      "例题" => 2,
      "片段" => 3
    }
  end

  def self.tag_type_for_select
    {
      "请选择" => -1,
      "索引" => 1,
      "知识片段" => 2,
      "例题" => 3,
      "截图" => 4
    }
  end

  def self.show_type(type_code)
    case type_code
    when 1
      "知识点"
    when 2
      "例题"
    when 3
      "片段"
    else
      "未知"
    end
  end

  def self.show_tag_type(tag_type_code)
    case tag_type_code
    when 1
      "索引"
    when 2
      "知识片段"
    when 3
      "例题"
    when 4
      "截图"
    else
      "未知"
    end
  end

  def duration
    begin
      v = FFMPEG::Movie.new("public#{self.video_url}")
      return v.duration.to_time
    rescue
      return 0
    end
  end

  def course_name
    course = self.lesson.course
    course.nil? ? "未绑定" : course.name
  end

  def lesson_name
    self.lesson.name
  end

  def video_order
    video_id_ary = self.lesson.video_id_ary
    index = video_id_ary.index(self.id.to_s)
    index == -1 ? "未指定序号" : index + 1
  end

  def info_for_tablet(lesson, order)
    {
      server_id: self.id.to_s,
      type: self.video_type,
      name: self.name,
      video_order: order,
      time: self.time.to_i,
      page: self.page || -1,
      question_name: self.question_name || "",
      content: self.content.join("^^^"),
      video_url: self.video_url,
      update_at: self.updated_at.to_s,
      lesson_id: lesson.id.to_s
    }
  end

  def tag_info_for_tablet
    self.tags.map do |t|
      {
        type: t["tag_type"],
        time: t["time"],
        name: t["name"] || "",
        duration: t["duration"] || 0,
        video_id: self.id.to_s,
        episode_id: t["episode_id"] || "",
        question_id: t["question_id"].join(',') || "",
        snapshot_id: t["snapshot_id"] || "",
        snapshot: t["snapshot_id"].present? ? Snapshot.find(t["snapshot_id"]).info_for_tablet : ""
      }
    end
  end
end
