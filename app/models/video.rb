# encoding: utf-8
class Video
  include Mongoid::Document
  include Mongoid::Timestamps

  # 1 for knowledge, 2 for example, 3 for episode
  field :video_type, type: Integer
  field :name, type: String
  field :video_url, type: String

  # structure of one element in tags:
  # => tag_type: String, can be index or episode
  # => time: Integer
  # => name: String, only for index tags
  # => episode_id: String, only for episode tags
  field :tags, type: Array

  # for example videos, the question content
  field :content, type: Array, default: []
  # for example videos, recommended finish time
  field :time, type: Integer

  belongs_to :lesson, class_name: "Lesson", inverse_of: :videos

  def self.video_type_for_select
    {
      "请选择" => -1,
      "知识点" => 1,
      "例题" => 2,
      "片段" => 3
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

  def info_for_tablet(lesson, order)
    {
      server_id: self.id.to_s,
      type: self.type,
      name: self.name,
      video_order: order,
      time: self.time,
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
        name: t["name"],
        episode_id: t["episode_id"]
      }
    end
  end
end
