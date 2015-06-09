#encoding: utf-8
class Admin::LocalCoursesController < Admin::ApplicationController

  def index
    @local_courses = auto_paginate LocalCourse.all
  end

  def create
    retval = LocalCourse.create_local_course(params[:local_course])
    flash[:notice] = "创建成功"
    redirect_to action: :index and return
  end

  def update
    @local_course = LocalCourse.find(params[:id])
    retval = @local_course.update_local_course(params[:local_course])
    flash[:notice] = "更新成功"
    redirect_to action: :index and return
  end

  def destroy
    @local_course = LocalCourse.find(params[:id])
    @local_course.destroy
    flash[:notice] = "删除成功"
    redirect_to action: :index and return
  end

  def new
    @local_course = LocalCourse.new
    @new = true
  end

  def edit
    @local_course = LocalCourse.find(params[:id])
    render action: :new
  end
end
