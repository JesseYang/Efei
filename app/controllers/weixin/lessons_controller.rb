# encoding: utf-8
class Weixin::LessonsController < Weixin::ApplicationController

  def exercise
    @local_course = LocalCourse.find(params[:local_course_id])
    @return_path = weixin_course_path(@local_course)
    @lesson = Lesson.find(params[:id])
    @title = @lesson.name

    @question_index = params[:q_index].to_i || 0
    @exercise = @lesson.homework
    @question_number = @exercise.q_ids.length
    @question = Question.find(@exercise.q_ids[@question_index])

    answer = Answer.ensure_answer(@current_user, @lesson.homework, @local_course.coach)
    @answer_content = answer.answer_content[@question.id.to_s]
  end

  def record
    @local_course = LocalCourse.find(params[:local_course_id])
    @return_path = weixin_course_path(@local_course)
    @lesson = Lesson.find(params[:id])
    @title = @lesson.name
  end
end
