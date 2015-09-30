# encoding: utf-8
class ActionLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :happen_at, type: Integer
  field :action, type: String
  field :video_id_1, type: String
  field :video_id_2, type: String
  field :video_time_1, type: Integer
  field :video_time_2, type: Integer
  field :question_id, type: String
  field :snapshot_id, type: String

  belongs_to :lesson
  belongs_to :student, class_name: "User", inverse_of: :action_logs

  def self.batch_create(logs)
    id_ary = [ ]
    logs.each do |l|
      id_ary << l.delete("id")
      auth_key = l.delete("auth_key")
      l["student_id"] = User.find_by_auth_key(auth_key).id.to_s
      ActionLog.create({
        happen_at: l["happen_at"],
        action: l["action"],
        video_id_1: l["video_id_1"],
        video_id_2: l["video_id_2"],
        video_time_1: l["video_time_1"],
        video_time_2: l["video_time_2"],
        question_id: l["question_id"],
        snapshot_id: l["snapshot_id"],
        student_id: l["student_id"]
      })
    end
    id_ary
  end
end
