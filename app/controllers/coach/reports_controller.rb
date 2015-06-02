# encoding: utf-8
class Coach::ReportsController < Coach::ApplicationController

  def new
    @student = User.find(params[:student_id])
    @local_course = LocalCourse.find(params[:local_course_id])

    @title = @student.name
  end
end
