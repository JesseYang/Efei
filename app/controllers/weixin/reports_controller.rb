# encoding: utf-8
class Weixin::ReportsController < Weixin::ApplicationController

  def show
    @title = "学情报告"
    @study_report = StudyReport.find(params[:id])
  end
end
