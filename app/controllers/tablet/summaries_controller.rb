# encoding: utf-8
class Tablet::SummariesController < Tablet::ApplicationController
  # params[:auth_key]
  # params[:snapshot_id]
  # params[:checked]
  # params[:analysis_answer]
  # params[:lesson_id]
  def create
    student = User.find_by_auth_key(params[:auth_key])
    snapshot = Snapshot.find(params[:snapshot_id])
    q = snapshot.question
    Summary.create_new(student, snapshot, params[:checked])
    if q.type == "analysis"
      l = Lesson.find(params[:lesson_id])
      if l.pre_test.q_ids.include?(q.id.to_s)
        e = l._pre_test
      elsif l.exercise.q_ids.include?(q.id.to_s)
        e = l.exercise
      elsif l.post_test.q_ids.include?(q.id.to_s)
        e = l.post_test
      end
      if e.present?
        tablet_answer = TabletAnswer.where(exercise_id: e.id, student_id: student.id).first
        if tablet_answer.present?
          tablet_answer.answer_content[q.id.to_s] = params[:analysis_answer].to_i
          tablet_answer.save
        end
      end
    end
    render json: { success: true } and return
  end
end
