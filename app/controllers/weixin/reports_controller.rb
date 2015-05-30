# encoding: utf-8
class Weixin::ReportsController < Weixin::ApplicationController

  def show
    @title = "学情报告"
    @study_report = StudyReport.find(params[:id])
    # @return_path = report_weixin_course_path(@study_report.local_course)
  end
end
