# encoding: utf-8
class Weixin::ReportsController < Weixin::ApplicationController

  skip_before_filter :weixin_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/reports") and return
  end

  def index
    @title = "学情报告"
    @local_courses = @current_user.student_local_courses
    @reports = current_user.student_study_reports
    if params[:local_course_id].present?
      @local_course = LocalCourse.find(params[:local_course_id])
      @reports = @reports.where(local_course_id: params[:local_course_id])
    end
  end

  def show
    @return_path = weixin_reports_path
    @title = "学情报告"
    @study_report = StudyReport.find(params[:id])
  end
end
