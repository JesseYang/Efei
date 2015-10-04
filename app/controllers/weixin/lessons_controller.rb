require 'array'
# encoding: utf-8
class Weixin::LessonsController < Weixin::ApplicationController

  def exercise
    @lesson = Lesson.find(params[:id])
    lesson_index = @lesson.course.lesson_id_ary.index(params[:id])
    @title = Lesson.lesson_helper(lesson_index) + @lesson.name
    @student = User.find(params[:student_id])

    @pre_test = @lesson.pre_test
    @exercise = @lesson.exercise
    @post_test = @lesson.post_test

    @pre_test_answer = @pre_test.tablet_answers.where(student_id: @student.id).first
    @exercise_answer = @exercise.tablet_answers.where(student_id: @student.id).first
    @post_test_answer = @post_test.tablet_answers.where(student_id: @student.id).first

    @exercises = [@post_test, @exercise, @pre_test]
    @answers = [@post_test_answer, @exercise_answer, @pre_test_answer]
  end

  def report
    @student = User.find(params[:student_id])
    @lesson = Lesson.find(params[:id])
    lesson_index = @lesson.course.lesson_id_ary.index(params[:id])
    @title = Lesson.lesson_helper(lesson_index) + @lesson.name
    @report = @student.reports.where(lesson_id: @lesson.id.to_s).first
  end

  def time_dist
    @report = User.find(params[:student_id]).reports.where(lesson_id: params[:id]).first
    render json: { success: true, data: @report.time_dist_desc } and return
  end

  def record
    @local_course = LocalCourse.find(params[:local_course_id])
    @return_path = weixin_course_path(@local_course)
    @lesson = Lesson.find(params[:id])
    lesson_index = @local_course.course.lesson_id_ary.index(params[:id])
    @title = Lesson.lesson_helper(lesson_index) + @lesson.name
  end
end
