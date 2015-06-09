#encoding: utf-8
class Admin::LocalCoursesController < Admin::ApplicationController

  def index
    @local_courses = auto_paginate LocalCourse.all
  end

  def create
  end

  def update
  end

  def destroy
    @local_course = LocalCourse.find(params[:id])
    @local_course.destroy
    redirect_to action: :index and return
  end
end
