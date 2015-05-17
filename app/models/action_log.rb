# encoding: utf-8
class ActionLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :happen_at, type: Integer
  field :action, type: String
  field :type, type: String
  field :video_time, type: Integer

  belongs_to :course
  belongs_to :lesson
  belongs_to :video
  belongs_to :student, class_name: "User", inverse_of: :action_logs

end
