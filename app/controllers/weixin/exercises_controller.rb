# encoding: utf-8
class Weixin::ExercisesController < Weixin::ApplicationController

  def show
    @local_course = LocalCourse.find(params[:local_course_id])
    @lesson = Lesson.find(params[:id])
    @index = params[:index].to_i

    # @return_path = exercise_weixin_course_path(@local_course)
    @title = "练习反馈"

    @question_index = params[:q_index].to_i || 0
    @exercise = @lesson.homework
    @question_number = @exercise.q_ids.length
    @question = Question.find(@exercise.q_ids[@question_index])

    answer = Answer.ensure_answer(@current_user, @lesson.homework, @local_course.coach)
    @answer_content = answer.answer_content[@question.id.to_s]
  end
end
