# encoding: utf-8
class Weixin::ReportsController < Weixin::ApplicationController

  def show
    @return_path = report_weixin_course_path(@study_report.local_course)
    @title = "学情报告"
    @study_report = StudyReport.find(params[:id])
  end
end
