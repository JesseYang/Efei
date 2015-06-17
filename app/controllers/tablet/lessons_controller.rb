# encoding: utf-8
class Tablet::LessonsController < Tablet::ApplicationController

  def index
  	course = Course.find(params[:course_id])
  	lessons = (course.lesson_id_ary || []).map { |e| Lesson.find(e) } .each_with_index.map do |l, i|
  		l.info_for_tablet(course, i)
  	end
    render_with_auth_key({lessons: lessons}) and return
  end
end
