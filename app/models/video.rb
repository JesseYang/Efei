# encoding: utf-8
class Video
  include Mongoid::Document
  include Mongoid::Timestamps

  # 1 for knowledge, 2 for example, 3 for episode
  field :video_type, type: Integer
  field :name, type: String

  # structure of one element in tags:
  # => tag_type: String, can be index or episode
  # => time: Integer
  # => name: String, only for index tags
  # => episode_id: String, only for episode tags
  field :tags, type: Array

  # for example videos, the question content
  field :content, type: Array
  # for example videos, recommended finish time
  field :time, type: Integer

end
