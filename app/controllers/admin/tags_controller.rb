#encoding: utf-8
class Admin::TagsController < Admin::ApplicationController

  def create
    @video = Video.find(params[:video_id])

    tag = {
      "tag_type" => params[:tag]["tag_type"].to_i,
      "name" => params[:tag]["name"],
      "time" => params[:tag]["time"].to_i
    }

    if params[:tag]["episode_id"].to_s != "-1"
      tag["episode_id"] = params[:tag]["episode_id"]
    end

    @video.tags << tag
    @video.save
    
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
