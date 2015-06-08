# encoding: utf-8
class Coach::StudentsController < Coach::ApplicationController
  skip_before_filter :coach_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/coach/students") and return
  end

  def index
    @title = "学生列表"
    @students = @current_user.current_students
  end

  def show
    @return_path = coach_students_path
    @student = User.where(id: params[:id]).first
    @title = @student.name
    @local_courses = @student.local_courses.where(coach_id: @current_user.id)
  end

  def exercise
    @student = User.where(id: params[:id]).first
    @return_path = coach_student_path(@student)
    @local_course = @student.student_local_courses.where(id: params[:local_course_id]).first
    @lessons = @local_course.course.lesson_id_ary.map { |e| Lesson.find(e) }
    @title = @student.name
  end

  def report
    @student = User.where(id: params[:id]).first
    @return_path = coach_student_path(@student)
    @local_course = LocalCourse.find(params[:local_course_id])
    @title = @student.name

    @reports = @student.student_study_reports.where(local_course_id: @local_course.id)
  end
end
