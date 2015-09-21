# encoding: utf-8
class Tablet::TabletAnswersController < Tablet::ApplicationController
  # params[:auth_key]
  # params[:exercise_id]
  # params[:tablet_answer]
  def create
    student = User.find_by_auth_key(params[:auth_key])
    exercise = Homework.find(params[:exercise_id])
    if params[:type] == "pre_test"
      TabletAnswer.create_new(student, exercise, params[:tablet_answer])
    elsif params[:type] == "exercise"
      TabletAnswer.update_exercise(student,exercise, params[:question_id], params[:answer], params[:duration])
    end
    render json: { success: true } and return
  end
end
