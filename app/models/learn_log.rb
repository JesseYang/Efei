# encoding: utf-8
class LearnLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :begin_at, type: Integer
  field :end_at, type: Integer
  field :type, type: String
  field :video_time, type: Integer

  belongs_to :course
  belongs_to :lesson
  belongs_to :video, class_name: "Video", inverse_of: :learn_logs

  # only for those which are video type logs, and the video is an episode
  belongs_to :original_video, class_name: "Video", inverse_of: :original_learn_logs
  belongs_to :student, class_name: "User", inverse_of: :learn_logs

end
