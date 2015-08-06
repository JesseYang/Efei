#encoding: utf-8
class Admin::StudentsController < Admin::ApplicationController

  def index
    @students = auto_paginate User.where(tablet: true)
  end

  def create
    retval = User.create_student(params[:student])
    flash[:notice] = "创建成功"
    redirect_to action: :index and return
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

  def download_cover
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    filename = @student.download_cover(@local_course)
    render json: { success: true, filename: filename }
  end
end
