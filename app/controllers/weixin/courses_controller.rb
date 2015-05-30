# encoding: utf-8
class Weixin::CoursesController < Weixin::ApplicationController
  skip_before_filter :weixin_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/courses") and return
  end

  def index
    @current = (params[:current] || 1).to_i
    @subject = (params[:subject] || 0).to_i
    @title = @current == 1 ? "我的当前课程" : "我的以往课程"
    if @subject != 0
      @title += "（#{Subject::NAME[@subject]}）"
    end

    @local_courses = current_user.student_local_courses

    if @current == 1
      # filter current courses
      @local_courses = @local_courses.select { |e| e.course.end_at > Time.now.to_i }
    else
      # filter old courses
      @local_courses = @local_courses.select { |e| e.course.end_at < Time.now.to_i }
    end

    if @subject != 0
      @local_courses = @local_courses.select { |e| e.subject == @subject }
    end
  end

  def exercise
    @local_course = LocalCourse.find(params[:id])
    @lessons = @local_course.course.lesson_id_ary.map { |e| Lesson.find(e) }
    @title = "练习反馈"
  end

  def report
    @local_course = LocalCourse.find(params[:id])
    @title = "学情报告"

    @reports = current_user.student_study_reports.where(local_course_id: @local_course.id)
  end

  def record
    @local_course = LocalCourse.find(params[:id])
    @title = "学习记录"
  end

  def schedule
    @local_course = LocalCourse.find(params[:id])
    @title = "进度追踪"
    @lesson_info = @local_course.course.lessons.map do |e|
      {
        name: e.name,
        finished: false
      }
    end
    @lesson_info[0][:finished_at] = "2015.4.3"
    @lesson_info[0][:finished] = true
    @lesson_info[1][:finished_at] = "2015.5.2"
    @lesson_info[1][:finished] = true
  end
end
