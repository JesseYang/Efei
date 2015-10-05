# encoding: utf-8
class Tablet::TabletAnswersController < Tablet::ApplicationController
  # params[:auth_key]
  # params[:exercise_id]
  # params[:tablet_answer]
  # params[:type]
  def create
    student = User.find_by_auth_key(params[:auth_key])
    exercise = Homework.find(params[:exercise_id])
    TabletAnswer.create_new(student, exercise, params[:tablet_answer], params[:type])
    render json: { success: true } and return
  end
end
