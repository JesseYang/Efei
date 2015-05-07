# encoding: utf-8
class Tablet::VideosController < Tablet::ApplicationController

  def index
  	lesson = Lesson.find(params[:lesson_id])
  	videos = lesson.video_id_ary.map { |e| Video.find(e) } .each_with_index.map do |v, i|
  		v.info_for_tablet(lesson, i)
  	end
    render_with_auth_key({videos: videos}) and return
  end
end
