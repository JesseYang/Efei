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

  ENTRY_LESSON = 0
  ENTRY_PRE_TEST = 1
  ENTRY_PRE_TEST_RESULT = 2
  ENTRY_VIDEO = 3
  PAUSE_VIDEO = 4
  PLAY_VIDEO = 5
  SWITCH_VIDEO = 6;
  ENTRY_EXERCISE = 7
  RETURN_FROM_EXERCISE = 8
  BEGIN_FORWARD = 9
  STOP_FORWARD = 10
  BEGIN_BACKWARD = 11
  STOP_BACKWARD = 12
  ENTRY_SUMMARY = 13
  RETURN_FROM_SUMMARY = 14
  ENTRY_POST_TEST = 15
  ENTRY_POST_TEST_RESULT = 16
  ENTRY_VIDEO_FROM_POST_TEST_RESULT = 17
  RETURN_POST_TEST_RESULT = 18
  LEAVE_LESSON = 19

  ENTRY_PRE_TEST_ARY = [ENTRY_PRE_TEST]
  ENTRY_VIDEO_ARY = [ENTRY_VIDEOO, PLAY_VIDEO, SWITCH_VIDEO, RETURN_FROM_EXERCISE, RETURN_FROM_SUMMARY, ENTRY_VIDEO_FROM_POST_TEST_RESULT]
  ENTRY_SUMMARY_ARY = [ENTRY_SUMMARY]
  ENTRY_EXERCISE_ARY = [ENTRY_EXERCISE]
  ENTRY_POST_TEST_ARY = [ENTRY_POST_TEST, RETURN_POST_TEST_RESULT]
  ENTRY_OTHER_ARY = [PAUSE_VIDEO]
  LEAVE_ARY = [LEAVE_LESSON]


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
