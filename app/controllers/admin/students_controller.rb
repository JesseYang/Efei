#encoding: utf-8
class Admin::StudentsController < Admin::ApplicationController

  def index
    @students = User.where(tablet: true)
    if params[:keyword].present?
      @students = @students.any_of({name: /#{params[:keyword]}/}, {email: /#{params[:keyword]}/}, {mobile: /#{params[:keyword]}/})
    end
    @students = auto_paginate @students
  end

  def create
    new_student = User.create_student(params[:student])
    flash[:notice] = "创建成功"
    redirect_to admin_student_path(new_student) and return
  end

  def show
    @student = User.find(params[:id])
  end

  def update
    @student = User.find(params[:id])
    @student.update_student(params[:student])
    flash[:notice] = "更新成功"
    redirect_to action: :index and return
  end

  def destroy
    @student = User.find(params[:id])
    @student.destroy
    flash[:notice] = "删除成功"
    redirect_to action: :index and return
  end

  def new
    @student = User.new
    @new = true
  end

  def edit
    @student = User.find(params[:id])
    render action: :new
  end

  def add_local_course
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    if !@student.student_local_courses.include?(@local_course)
      @student.student_local_courses << @local_course
    end
    render json: { success: true }
  end

  def remove_local_course
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    @student.student_local_courses.delete(@local_course)
    render json: { success: true }
  end

  def download_schedule
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    filename = @student.download_schedule(@local_course)
    render json: { success: true, filename: filename }
  end

  def download_cover
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    filename = @student.download_cover(@local_course)
    render json: { success: true, filename: filename }
  end
end
