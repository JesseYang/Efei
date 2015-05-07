# encoding: utf-8
class Tablet::TagsController < Tablet::ApplicationController

  def index
  	video = Video.find(params[:video_id])
    render_with_auth_key({tags: video.tag_info_for_tablet}) and return
  end
end
