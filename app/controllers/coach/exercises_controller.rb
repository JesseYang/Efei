# encoding: utf-8
class Coach::ExercisesController < Coach::ApplicationController

  def show
    @student = User.where(id: params[:student_id]).first
    @local_course = LocalCourse.find(params[:local_course_id])
    @lesson = Lesson.find(params[:id])
    @index = params[:index].to_i

    @title = @student.name

    @question_index = params[:q_index].to_i || 0
    @exercise = @lesson.homework
    @question_number = @exercise.q_ids.length
    @question = Question.find(@exercise.q_ids[@question_index])
  end
end
