#encoding: utf-8
class Admin::TagsController < Admin::ApplicationController

  def create
    @video = Video.find(params[:video_id])
    @all_videos = Video.where(video_url: @video.video_url)

    if params[:tag]["tag_type"].to_i != 4
      tag = {
        "tag_type" => params[:tag]["tag_type"].to_i,
        "name" => params[:tag]["name"],
        "time" => params[:tag]["time"].to_i,
        "duration" => params[:tag]["duration"].to_i
      }

      if params[:tag]["episode_id"].to_s != "-1"
        tag["episode_id"] = params[:tag]["episode_id"]
      end

      tag["question_id"] = params[:tag]["question_id"].split(',')
    else
      snapshot = Snapshot.find(params[:tag]["snapshot_id"])
      tag = {
        "tag_type" => params[:tag]["tag_type"].to_i,
        "time" => snapshot.time.round,
        "snapshot_id" => snapshot.id.to_s
      }
    end

    @all_videos.each do |v|
      v.tags << tag
      v.save
    end
    
    redirect_to controller: "admin/videos", action: :show, id: @video.id.to_s and return
  end

  def destroy 
    @video = Video.find(params[:video_id])
    index = @video.tags.index { |e| e["time"].to_i == params[:id].to_i }
    if index != -1
      @video.tags.delete_at(index)
      @video.save
    end
    redirect_to controller: "admin/videos", action: :show, id: @video.id.to_s and return
  end
end
