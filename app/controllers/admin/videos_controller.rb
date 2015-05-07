#encoding: utf-8
class Admin::VideosController < Admin::ApplicationController

  def index
    @lesson = Lesson.find(params[:lesson_id])
    @videos = [ ]
    @lesson.video_id_ary.each do |vid|
      next if vid.blank?
      @videos << Video.find(vid)
    end
  end

  def show
    @video = Video.find(params[:id])
  end

  def create
    if params[:existing_video_content].to_s != "-1"
      existing_video = Video.find(params[:existing_video_content])
      video_url = existing_video.video_url
    else
      # save the video content file
      video_content = VideoContent.new
      video_content.video = params[:video_content]
      filetype = "mp4"
      video_content.store_video!
      filepath = video_content.video.file.file
      video_url = "/videos/" + filepath.split("/")[-1]
    end

    lesson = Lesson.find(params[:video]["lesson_id"])

    @video = Video.new(video_type: params[:video]["video_type"].to_i,
      name: params[:video]["name"],
      video_url: video_url)
    @video.lesson = lesson
    @video.save

    # update the lesson_id_ary for the course
    index = params[:video]["order"].to_i - 1
    if index >= 0
      lesson.video_id_ary ||= []
      lesson.video_id_ary[index] = @video.id.to_s
      lesson.save
    end

    @video.touch_parents

    redirect_to action: :index, lesson_id: lesson.id.to_s and return
  end

  def destroy
    @video = Video.find(params[:id])
    lesson = @video.lesson
    if lesson.present?
      video_index = lesson.video_id_ary.index(@video.id.to_s)
      if video_index != -1
        lesson.video_id_ary[video_index] = nil
        lesson.save
      end
    end
    # remove the video file
    File.delete("public" + @video.video_url)
    @video.destroy
    redirect_to action: :index, lesson_id: lesson.id.to_s and return
  end
end
