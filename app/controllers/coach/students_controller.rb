# encoding: utf-8
class Coach::StudentsController < Coach::ApplicationController
  skip_before_filter :coach_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/coach/students") and return
  end

  def index
    @title = "学生列表"
    @students = @current_user.students
  end

  def show
    @return_path = coach_students_path
    @student = User.where(id: params[:id]).first
    @title = @student.name + "的课程"
    @courses = @student.student_courses

    image_url = "public/pdf/#{@student.id.to_s}.png"
    if !File.exist?(image_url)
      qr = RQRCode::QRCode.new(@student.id.to_s, :size => 4, :level => :h )
      png = qr.to_img
      png.resize(150, 150).save(image_url)
    end
    @image_url = "/pdf/#{@student.id.to_s}.png"

  end

  def course
    @student = User.where(id: params[:id]).first
    @return_path = coach_student_path(@student)
    @course = Course.find(params[:course_id])
    @title = @student.name
  end

  def exercise
    @student = User.where(id: params[:id]).first
    @lesson = Lesson.find(params[:lesson_id])
    @course = @lesson.course
    @return_path = course_coach_student_path(@student) + "?course_id=" + @course.id.to_s
    @title = @student.name

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
    @student = User.where(id: params[:id]).first
    @lesson = Lesson.find(params[:lesson_id])
    @course = @lesson.course
    @return_path = course_coach_student_path(@student) + "?course_id=" + @course.id.to_s
    @title = @student.name
    @report = @student.reports.where(lesson_id: @lesson.id.to_s).first
  end
end
