# encoding: utf-8
class Tablet::HomeworksController < Tablet::ApplicationController

  def index
    pre_test = Homework.where(lesson_pre_test_id: params[:lesson_id]).first
    post_test = Homework.where(lesson_post_test_id: params[:lesson_id]).first
    exercise = Homework.where(lesson_exercise_id: params[:lesson_id]).first
    homeworks = [ ]
    homeworks << pre_test.info_for_tablet if pre_test.present?
    homeworks << post_test.info_for_tablet if post_test.present?
    homeworks << exercise.info_for_tablet if exercise.present?
    render_with_auth_key({homeworks: homeworks}) and return
  end
end
