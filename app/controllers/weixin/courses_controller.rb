# encoding: utf-8
class Weixin::CoursesController < Weixin::ApplicationController
  skip_before_filter :weixin_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/courses") and return
  end

  def index
    # redirect to the recent course page
    @course = @current_user.student_courses.first
    redirect_to weixin_course_path(@course) and return
=begin
    @current = (params[:current] || 1).to_i
    @subject = (params[:subject] || 0).to_i
    @title = @current == 1 ? "我的当前课程" : "我的以往课程"
    if @subject != 0
      @title += "（#{Subject::NAME[@subject]}）"
    end

    @local_courses = @current_user.student_local_courses

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
=end
  end

  def show
    @course = Course.find(params[:id])
    @lessons = @course.lesson_id_ary.map { |e| Lesson.find(e) }
    @title = @course.name
  end

  def exercise
    @return_path = weixin_courses_path
    @local_course = LocalCourse.find(params[:id])
    @lessons = @local_course.course.lesson_id_ary.map { |e| Lesson.find(e) }
    @title = "练习反馈"
  end

  def report
    @return_path = weixin_courses_path
    @local_course = LocalCourse.find(params[:id])
    @title = "学情报告"
    @reports = current_user.student_study_reports.where(local_course_id: @local_course.id)
  end

  def record
    @return_path = weixin_courses_path
    @local_course = LocalCourse.find(params[:id])
    @title = "学习记录"
  end

  def schedule
    @return_path = weixin_courses_path
    @local_course = LocalCourse.find(params[:id])
    @title = "进度追踪"
    @lesson_info = @local_course.course.lesson_id_ary.map do |l_id|
      lesson = Lesson.find(l_id)
      a = Answer.ensure_answer(@current_user, lesson.homework, @local_course.coach)
      info = {
        name: lesson.name,
        finished: a.try(:finish) || false
      }
      if a.present? && a.finish && a.finished_at.present?
        info[:finished_at] = Time.at(a.finished_at).strftime("%Y.%m.%d")
      end
      info
    end
  end
end
