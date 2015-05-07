#encoding: utf-8
class Admin::CoursesController < Admin::ApplicationController

  def index
    @courses = Course.all
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

    start_at = Time.mktime(*params[:course]["start_at"].split("."))
    end_at = Time.mktime(*params[:course]["end_at"].split("."))
    teacher = User.find(params[:course]["teacher_id"])

    @course = Course.new(name: params[:course]["name"],
      subject: params[:course]["subject"],
      start_at: start_at,
      end_at: end_at,
      grade: params[:course]["grade"],
      desc: params[:course]["desc"],
      suggestion: params[:course]["suggestion"],
      textbook_url: textbook_url)
    @course.teacher = teacher
    @course.save
    redirect_to action: :index and return
  end

  def destroy
    c = Course.find(params[:id])
    if c.lesson_id_ary.blank?
      c.destroy
      # remove the textbook file
      File.delete("public" + c.textbook_url)
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
