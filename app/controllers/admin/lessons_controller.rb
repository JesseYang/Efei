#encoding: utf-8
class Admin::LessonsController < Admin::ApplicationController

  def index
    if params[:course_id].blank?
      @lessons = Lesson.all
    else
      @course = Course.find(params[:course_id])
      @lessons = @course.lessons
    end
  end

  def show
  end

  def create
    course = Course.find(params[:lesson]["course_id"])

    @lesson = Lesson.new(name: params[:lesson]["name"])
    @lesson.course = course
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
    if @lesson.videos.blank? && @lesson.video_id_ary.blank?
      course = @lesson.course
      if course.present?
        lesson_index = course.lesson_id_ary.index(@lesson.id.to_s)
        if lesson_index != -1
          course.lesson_id_ary[lesson_index] = nil
          course.save
        end
      end
      @lesson.destroy
    end
    redirect_to action: :index and return
  end
end
