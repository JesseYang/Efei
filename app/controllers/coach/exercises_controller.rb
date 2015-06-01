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

    answer = Answer.ensure_answer(@student, @exercise, @current_user)
    @answer_content = answer.answer_content[@question.id.to_s] || { }
  end

  # update answer for one question
  def update
    @question = Question.find(params[:id])
    @student = User.find(params[:student_id])
    @exercise = Homework.find(params[:exercise_id])
    answer = Answer.ensure_answer(@student, @exercise, @current_user)
    answer.update_answer_content(@question.id.to_s, params[:answer_content])
    render json: { success: true } and return
  end

  def submit
    @student = User.find(params[:student_id])
    @lesson = Lesson.find(params[:id])
    answer = Answer.ensure_answer(@student, @lesson.homework, @current_user)
    retval = answer.submit
    render json: { success: retval } and return
  end
end
