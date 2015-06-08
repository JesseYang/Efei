# encoding: utf-8
class Weixin::ReportsController < Weixin::ApplicationController

  skip_before_filter :weixin_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/reports") and return
  end

  def index
    # @local_course = LocalCourse.find(params[:id])
    @title = "学情报告"
    @reports = current_user.student_study_reports
  end

  def show
    @return_path = weixin_reports_path
    @title = "学情报告"
    @study_report = StudyReport.find(params[:id])
  end
end
