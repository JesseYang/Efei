# encoding: utf-8
require 'integer'
class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :finish, type: Boolean, default: false
  # calculate from logs
  field :study_time, type: Array, default: [ ]
  # calculate from tablet answer and homeworks
  field :point_score, type: Hash, default: { }
  # calculate from logs
  field :time_dist, type: Hash, default: { }
  # calculate from logs and videos
  field :video_dist, type: Hash, default: { }

  belongs_to :lesson, class_name: "Lesson", inverse_of: :reports
  belongs_to :student, class_name: "User", inverse_of: :reports

  def self.find_or_create_new(lesson, user)
    r = Report.where(lesson_id: lesson.id, student_id: user.id).first || Report.create(lesson_id: lesson.id, student_id: user.id)
    if r.finish
      return r
    else
      post_test = r.lesson.post_test
      post_test_answer = post_test.tablet_answers.where(student_id: r.student_id).first
      action_logs = ActionLog.where(lesson_id: r.lesson_id, student_id: r.student_id).asc(:happen_at)
      if post_test_answer.present?
        r.update_attribute(:finish, true)
        r.calculate_point_score
        r.calculate_study_time(action_logs)
        r.calculate_time_dist(action_logs)
        r.calculate_video_dist(action_logs)
      end
      return r
    end
  end

  def self.finish_lesson?(lesson, user)
    r = Report.where(lesson_id: lesson.id, student_id: user.id).first
    r.present? && r.finish
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

    result = { "pre" => 0, "post" => 0, "knowledge" => { } }
    norm = { "pre" => 0, "post" => 0, "knowledge" => { } }

    pre_qs = { }
    pre_test.q_ids.each do |pre_test_qid|
      knowledge = pre_test.q_knowledges[pre_test_qid]
      total = pre_test.q_scores[pre_test_qid]
      score = pre_test_answer.get_score(pre_test_qid)
      pre_qs[pre_test_qid] = [knowledge, score, total]
      result["pre"] += score * total
      norm["pre"] += total
      result["knowledge"][knowledge] ||= [0, 0]
      result["knowledge"][knowledge][0] += score * total
      norm["knowledge"][knowledge] ||= [0, 0]
      norm["knowledge"][knowledge][0] += total
    end

    post_qs = { }
    post_test.q_ids.each do |post_test_qid|
      knowledge = post_test.q_knowledges[post_test_qid]
      total = post_test.q_scores[post_test_qid]
      score = post_test_answer.get_score(post_test_qid)
      post_qs[post_test_qid] = [knowledge, score, total]
      result["post"] += score * total
      norm["post"] += total
      result["knowledge"][knowledge] ||= [0, 0]
      result["knowledge"][knowledge][1] += score * total
      norm["knowledge"][knowledge] ||= [0, 0]
      norm["knowledge"][knowledge][1] += total
    end

    exercise_qs = { }
    exercise.q_ids.each do |exercise_qid|
      knowledge = exercise.q_knowledges[exercise_qid]
      total = exercise.q_scores[exercise_qid]
      score = exercise_answer.get_score(exercise_qid)
      exercise_qs[exercise_qid] = [knowledge, score, total]
      result["post"] += score * total
      norm["post"] += total
      result["knowledge"][knowledge] ||= [0, 0]
      result["knowledge"][knowledge][1] += score * total
      norm["knowledge"][knowledge] ||= [0, 0]
      norm["knowledge"][knowledge][1] += total
    end

    result["pre"] = result["pre"] / norm["pre"] * 100
    result["post"] = result["post"] / norm["post"] * 100

    result["knowledge"].each do |k, v|
      result["knowledge"][k][0] = result["knowledge"][k][0] / norm["knowledge"][k][0] * 10
      result["knowledge"][k][1] = result["knowledge"][k][1] / norm["knowledge"][k][1] * 10
    end

    self.point_score = result
    self.save
  end

  def calculate_study_time
    action_logs = ActionLog.where(lesson_id: self.lesson_id, student_id: self.student_id).asc(:happen_at)
    action_logs = action_logs.where(:action.in => [ActionLog::ENTRY_LESSON, ActionLog:: LEAVE_LESSON])
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

  def calculate_video_dist
    action_logs = ActionLog.where(lesson_id: self.lesson_id, student_id: self.student_id).asc(:happen_at)
    video_dist = { }
    watch_video = false
    current_knowledge = ""
    cur_start_time = 0
    action_logs.each do |log|
      if log.action == ActionLog::SWITCH_VIDEO
        if watch_video
          # first calculate last video time
          if current_knowledge.present?
            video_dist[current_knowledge] ||= 0
            video_dist[current_knowledge] += log.happen_at - cur_start_time
          end
        end
        # then enter next video
        current_knowledge = log.video.knowledge
        cur_start_time = log.happen_at
        watch_video = true
        next
      end
      if watch_video
        # find leave video log
        if ActionLog::LEAVE_VIDEO_ARY.include? log.action
          if current_knowledge.present?
            video_dist[current_knowledge] ||= 0
            video_dist[current_knowledge] += log.happen_at - cur_start_time
          end
          watch_video = false
        end
      else
        # find enter video log
        if ActionLog::ENTRY_VIDEO_ARY.include? log.action
          current_knowledge = log.video.knowledge
          cur_start_time = log.happen_at
          watch_video = true
        end
      end
    end
    self.video_dist = video_dist
    self.save
  end

  def calculate_time_dist
    action_logs = ActionLog.where(lesson_id: self.lesson_id, student_id: self.student_id).asc(:happen_at)
    time_dist = { "video" => 0, "pre_test" => 0, "snapshot" => 0, "exercise" => 0, "post_test" => 0, "other" => 0 }
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
    self.point_score["pre"]
  end

  def post_score
    self.point_score["post"]
  end

  def video_dist_desc
    desc = [ ]
    self.video_dist.each do |k, v|
      next if k.blank? || v == 0
      desc << [k, v]
    end
    desc
  end

  def study_content_desc
    knowledge = [ ]
    self.video_dist.each do |k, v|
      knowledge << k
    end
    desc = self.lesson.name + "，具体包括"
    knowledge.each_with_index do |k, i|
      if i < knowledge.length - 2
        desc += k + "、"
      elsif i < knowledge.length - 1
        desc += k + "以及"
      else
        desc += k
      end
    end
    desc
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
