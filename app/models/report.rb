# encoding: utf-8
require 'integer'
class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  # calculate from logs
  field :study_time, type: Array, default: [ ]
  # calculate from tablet answer and homeworks
  field :point_score, type: Hash, default: { }
  # calculate from logs
  field :time_dist, type: Hash, default: { }

  belongs_to :lesson, class_name: "Lesson", inverse_of: :reports
  belongs_to :student, class_name: "User", inverse_of: :reports

  def self.create_new(lesson, user)
    r = Report.create(lesson_id: lesson.id, student_id: user.id)
    r.calculate_point_score
    r.calculate_study_time
    r.calculate_time_dist
    r
  end

  def self.point_score_init_ele
    {
      pre_score: 0,
      pre_total_score: 0,
      post_score: 0,
      post_total_score: 0,
      exercise_score: 0,
      exercise_total_score: 0,
      pre_test_qid: [ ],
      post_test_qid: [ ],
      exercise_qid: [ ]
    }
  end

  def calculate_point_score
    point_score = { }
    pre_test = self.lesson.pre_test
    post_test = self.lesson.post_test
    exercise = self.lesson.exercise
    pre_test_answer = pre_test.tablet_answers.where(student_id: self.student_id).first
    exercise_answer = exercise.tablet_answers.where(student_id: self.student_id).first
    post_test_answer = post_test.tablet_answers.where(student_id: self.student_id).first
    pre_test.q_ids.each do |pre_test_qid|
      knowledge = pre_test.q_knowledges[pre_test_qid]
      ele = point_score[knowledge] || Report.point_score_init_ele
      ele[:pre_test_qid] << pre_test_qid
      ele[:pre_total_score] += pre_test.q_scores[pre_test_qid]
      ele[:pre_score] += pre_test_answer.is_correct?(pre_test_qid) ? pre_test.q_scores[pre_test_qid] : 0
      point_score[knowledge] = ele
    end
    exercise.q_ids.each do |exercise_qid|
      knowledge = exercise.q_knowledges[exercise_qid]
      ele = point_score[knowledge] || Report.point_score_init_ele
      ele[:exercise_qid] << exercise_qid
      ele[:exercise_total_score] += exercise.q_scores[exercise_qid]
      ele[:exercise_score] += exercise_answer.is_correct?(exercise_qid) ? exercise.q_scores[exercise_qid] : 0
      point_score[knowledge] = ele
    end
    post_test.q_ids.each do |post_test_qid|
      knowledge = post_test.q_knowledges[post_test_qid]
      ele = point_score[knowledge] || Report.point_score_init_ele
      ele[:post_test_qid] << post_test_qid
      ele[:post_total_score] += post_test.q_scores[post_test_qid]
      ele[:post_score] += post_test_answer.is_correct?(post_test_qid) ? post_test.q_scores[post_test_qid] : 0
      point_score[knowledge] = ele
    end
    self.point_score = point_score
    self.save
  end

  def calculate_study_time
    action_logs = ActionLog.where(lesson_id: self.lesson_id, student_id: self.student_id)
      .where(:action.in => [ActionLog::ENTRY_LESSON, ActionLog:: LEAVE_LESSON]).asc(:happen_at)
    study_time = [ ]
    start_time = 0
    action_logs.each do |log|
      if log.action == ActionLog::ENTRY_LESSON
        start_time = log.happen_at
      else
        if start_time != 0
          study_time << [start_time, log.happen_at]
          start_time = 0
        end
      end
    end
    self.study_time = study_time
    self.save
  end

  def calculate_time_dist
    action_logs = ActionLog.where(lesson_id: self.lesson_id, student_id: self.student_id).asc(:happen_at)
    time_dist = { "pre_test" => 0, "video" => 0, "snapshot" => 0, "exercise" => 0, "post_test" => 0, "other" => 0 }
    status = nil
    last_time = 0
    action_logs.each do |log|
      new_status = nil
      if ActionLog::ENTRY_PRE_TEST_ARY.include? log.action
        new_status = "pre_test"
      elsif ActionLog::ENTRY_VIDEO_ARY.include? log.action
        new_status = "video"
      elsif ActionLog::ENTRY_SUMMARY_ARY.include? log.action
        new_status = "snapshot"
      elsif ActionLog::ENTRY_EXERCISE_ARY.include? log.action
        new_status = "exercise"
      elsif ActionLog::ENTRY_POST_TEST_ARY.include? log.action
        new_status = "post_test"
      elsif ActionLog::ENTRY_OTHER_ARY.include? log.action
        new_status = "other"
      elsif ActionLog::LEAVE_ARY.include? log.action
        new_status = "none"
      else
        next
      end
      if status.present?
        puts time_dist
        time_dist[status] += log.happen_at - last_time
      end
      status = new_status == "none" ? nil : new_status
      last_time = log.happen_at
    end
    self.time_dist = time_dist
    self.save
  end

  def total_time
    total_time = 0
    self.study_time.each do |e|
      total_time += e[1] - e[0]
    end
    total_time.to_time
  end

  def pre_score
    pre_score = 0
    self.point_score.each do |k, v|
      pre_score += v["pre_score"]
    end
    pre_score
  end

  def post_score
    post_score = 0
    self.point_score.each do |k, v|
      post_score += v["post_score"]
    end
    post_score
  end

  def time_dist_desc
    desc = [ ]
    self.time_dist.each do |k, v|
      next if v == 0
      case k
      when "pre_test"
        desc << ["课前例题", v]
      when "video"
        desc << ["课程视频", v]
      when "snapshot"
        desc << ["题目反思总结", v]
      when "exercise"
        desc << ["课上练习", v]
      when "post_test"
        desc << ["课后测试", v]
      when "other"
        desc << ["其他", v]
      end
    end
    desc
  end
end
