# encoding: utf-8
class Coach::ReportsController < Coach::ApplicationController

  def new
    @student = User.find(params[:student_id])
    @local_course = LocalCourse.find(params[:local_course_id])

    @title = @student.name
    @report_id = ""
  end

  def create
    sr_id = StudyReport.create_new(params[:content])
    render json: { success: true, report_id: sr_id } and return
  end

  def update
    sr = StudyReport.find(params[:id])
    sr.update_existing(params[:content])
    render json: { success: true } and return
  end

  def submit
    sr = StudyReport.find(params[:id])
    sr.submit
    render json: { success: true } and return
  end
end
