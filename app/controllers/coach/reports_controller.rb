# encoding: utf-8
class Coach::ReportsController < Coach::ApplicationController

  def new
    @student = User.find(params[:student_id])
    @return_path = report_coach_student_path(@student) + "?local_course_id=#{params[:local_course_id]}"
    @local_course = LocalCourse.find(params[:local_course_id])

    @title = @student.name
    @report_id = ""
  end

  def show
    @student = User.find(params[:student_id])
    @return_path = report_coach_student_path(@student) + "?local_course_id=#{params[:local_course_id]}"
    @local_course = LocalCourse.find(params[:local_course_id])
    
    @title = @student.name
    @report_id = params[:id]
    @report = StudyReport.find(@report_id)
    render action: :new and return
  end

  def create
    student = User.find(params[:student_id])
    local_course = LocalCourse.find(params[:local_course_id])
    sr_id = StudyReport.create_new(params[:content], student, local_course)
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
