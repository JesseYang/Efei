#encoding: utf-8
class Admin::CoursesController < Admin::ApplicationController

  def index
    @courses = auto_paginate Course.filter(params[:subject].to_i, params[:type].to_i, params[:status].to_i)
  end

  def show
    @course = Course.find(params[:id])
  end

  def create
    # save the avatar file
    textbook = Textbook.new
    textbook.textbook = params[:textbook]
    filetype = "png"
    textbook.store_textbook!
    filepath = textbook.textbook.file.file
    textbook_url = "/textbooks/" + filepath.split("/")[-1]

    # start_at = Time.mktime(*params[:course]["start_at"].split("/"))
    # end_at = Time.mktime(*params[:course]["end_at"].split("/"))
    teacher = User.find(params[:course]["teacher_id"])

    @course = Course.new(name: params[:course]["name"],
      subject: params[:course]["subject"],
      course_type: params[:course]["type"],
      # start_at: start_at,
      # end_at: end_at,
      grade: params[:course]["grade"],
      desc: params[:course]["desc"],
      suggestion: params[:course]["suggestion"],
      textbook_url: textbook_url)
    @course.teacher = teacher
    @course.save
    redirect_to action: :index and return
  end

  def update
    c = Course.find(params[:id])

    if params[:textbook].present?
      # save the textbook image and update
      textbook = Textbook.new
      textbook.textbook = params[:textbook]
      filetype = "png"
      # save the textbook image and update
      textbook.store_textbook!
      filepath = textbook.textbook.file.file
      textbook_url = "/textbooks/" + filepath.split("/")[-1]
      old_url = c.textbook_url
      c.textbook_url = textbook_url

      # delete the old textbook image
      if File.exist?("public" + old_url)
        File.delete("public" + old_url)
      end
    end
    c.name = params[:course]["name"]
    c.subject = params[:course]["subject"]
    c.course_type = params[:course]["type"]
    # start_at = Time.mktime(*params[:course]["start_at"].split("/"))
    # end_at = Time.mktime(*params[:course]["end_at"].split("/"))
    # c.start_at = start_at
    # c.end_at = end_at
    c.grade = params[:course]["grade"]
    c.desc = params[:course]["desc"]
    c.suggestion = params[:course]["suggestion"]

    c.save
    flash[:notice] = "更新成功"
    redirect_to action: :index and return
  end

  def destroy
    c = Course.find(params[:id])
    if !c.has_lesson?
      c.destroy
      # remove the textbook file
      if File.exist?("public" + c.textbook_url)
        File.delete("public" + c.textbook_url)
      end
    end
    redirect_to action: :index and return
  end

  def toggle_ready
    @course = Course.find(params[:id])
    @course.ready = !@course.ready
    @course.save
    redirect_to action: :index and return
  end
end
