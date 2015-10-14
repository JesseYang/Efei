#encoding: utf-8
class Admin::LessonsController < Admin::ApplicationController

  def index
    if params[:course_id].blank?
      @lessons = Lesson.all
    else
      @course = Course.find(params[:course_id])
      @lessons = (@course.lesson_id_ary || []).map { |e| e.present? ? Lesson.find(e) : nil }
      @lessons = @lessons.select { |e| e.present? }
    end
  end

  def list
    c = Course.find(params[:course_id])
    @lessons = c.lesson_id_ary.map { |e| Lesson.find(e) }
    hash = { "请选择" => -1 }
    @lessons.each_with_index do |l, i|
      hash["第" + (i+1).to_s + "讲：" + l.name] = l.id.to_s
    end
    render json: { success: true, data: hash } and return
  end

  def show
  end

  def update
    @lesson = Lesson.find(params[:id])
    course = @lesson.course

    @lesson.name = params[:lesson]["name"]

    if params[:lesson]["pre_test_id"] == "-1"
      @lesson.pre_test = nil
    else
      pre_test = Homework.where(id: params[:lesson]["pre_test_id"]).first
      @lesson.pre_test = pre_test if pre_test.present? && pre_test != @lesson.pre_test
    end
    if params[:lesson]["exercise_id"] == "-1"
      @lesson.exercise = nil
    else
      exercise = Homework.where(id: params[:lesson]["exercise_id"]).first
      @lesson.exercise = exercise if exercise.present? && exercise != @lesson.exercise
    end
    if params[:lesson]["post_test_id"] == "-1"
      @lesson.post_test = nil
    else
      post_test = Homework.where(id: params[:lesson]["post_test_id"]).first
      @lesson.post_test = post_test if post_test.present? && post_test != @lesson.post_test
    end
    
    # update the lesson_id_ary for the course
    index = params[:lesson]["order"].to_i - 1
    if index >= 0
      course.lesson_id_ary ||= []
      course.lesson_id_ary[index] = @lesson.id.to_s
      course.save
    end
    @lesson.save

    redirect_to action: :index, course_id: course.id and return
  end

  def create
    course = Course.find(params[:lesson]["course_id"])

    @lesson = Lesson.new(name: params[:lesson]["name"])
    @lesson.course = course
    @lesson.save
    pre_test = Homework.where(id: params[:lesson]["pre_test_id"]).first
    @lesson.pre_test = pre_test if pre_test.present?
    exercise = Homework.where(id: params[:lesson]["exercise_id"]).first
    @lesson.exercise = exercise if exercise.present?
    post_test = Homework.where(id: params[:lesson]["post_test_id"]).first
    @lesson.post_test = post_test if post_test.present?
    @lesson.save
    @lesson.touch_parents

    # update the lesson_id_ary for the course
    index = params[:lesson]["order"].to_i - 1
    if index >= 0
      course.lesson_id_ary ||= []
      course.lesson_id_ary[index] = @lesson.id.to_s
      course.save
    end

    redirect_to action: :index, course_id: course.id and return
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    course = @lesson.course
    if !@lesson.has_video?
      if course.present?
        course.lesson_id_ary.delete(@lesson.id.to_s)
        course.save
      end
      @lesson.destroy
    end
    redirect_to action: :index, course_id: course.id.to_s and return
  end
end
