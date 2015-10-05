# encoding: utf-8
class Client::StudentsController < Client::ApplicationController
  skip_before_filter :client_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/client/students") and return
  end

  def index
    @return_path = main_page_client_users_path
    @title = "学生列表"
    @students = @current_user.client_students
  end

  def new
    @title = "创建学生"
  end

  def create
    c = User.create_student(params[:student].merge({"client_id" => @current_user.id.to_s}))
    redirect_to client_students_path and return
  end

  def update
    @student = User.find(params[:id])
    retval = @student.update_student(params[:student])
    if retval == true
      flash[:notice] = "更新成功"
    end
    redirect_to client_student_path(@student) and return
  end

  def show
    @return_path = client_students_path
    @student = User.find(params[:id])
    @title = @student.name
  end

  def coaches
    @return_path = client_students_path
    @student = User.find(params[:id])
    @coaches = @student.coaches
    @title = @student.name + "的老师"
  end

  def new_coach
    @student = User.find(params[:id])
    @coach = @current_user.client_coaches.where(name: params[:new_coach]).first
    @student.coaches << @coach
    flash[:notice] = "添加成功"
    redirect_to action: :coaches and return
  end

  def delete_coach
    @student = User.find(params[:id])
    @coach = @current_user.client_coaches.where(id: params[:coach_id]).first
    if @coach.present?
      @student.coaches.delete(@coach)
      flash[:notice] = "删除成功"
    end
    redirect_to action: :coaches and return
  end

  def courses
    @return_path = client_students_path
    @student = User.find(params[:id])
    @courses = @student.student_courses
    @title = @student.name + "的课程"
  end

  def new_course
    @student = User.find(params[:id])
    @course = Course.where(name: params[:new_course]).first
    @student.student_courses << @course
    flash[:notice] = "添加成功"
    redirect_to action: :courses and return
  end

  def delete_course
    @student = User.find(params[:id])
    @course = Course.find(params[:course_id])
    @student.student_courses.delete(@course)
    flash[:notice] = "删除成功"
    redirect_to action: :courses and return
  end
end
