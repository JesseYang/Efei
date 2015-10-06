# encoding: utf-8
class Tablet::TabletAnswersController < Tablet::ApplicationController
  # params[:auth_key]
  # params[:exercise_id]
  # params[:tablet_answer]
  # params[:type]
  def create
    student = User.find_by_auth_key(params[:auth_key])
    exercise = Homework.find(params[:exercise_id])
    qid_ary = params[:question_id].split(',')
    TabletAnswer.create_new(student, exercise, qid_ary, params[:tablet_answer], params[:type])
    render json: { success: true } and return
  end
end
