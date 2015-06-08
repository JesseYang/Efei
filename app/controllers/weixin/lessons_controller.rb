# encoding: utf-8
class Weixin::LessonsController < Weixin::ApplicationController

  def exercise
    @local_course = LocalCourse.find(params[:local_course_id])
    @return_path = weixin_course_path(@local_course)
    @lesson = Lesson.find(params[:id])
    @title = Lesson.lesson_helper + @lesson.name

    @exercise = @lesson.homework
    @answer = Answer.ensure_answer(@current_user, @lesson.homework, @local_course.coach)
  end

  def record
    @local_course = LocalCourse.find(params[:local_course_id])
    @return_path = weixin_course_path(@local_course)
    @lesson = Lesson.find(params[:id])
    @title = Lesson.lesson_helper + @lesson.name
  end
end
