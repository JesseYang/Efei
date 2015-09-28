#encoding: utf-8
class Admin::SnapshotsController < Admin::ApplicationController

  def create
    @video = Video.find(params[:video_id])
    s = Snapshot.create(
      time: params[:time],
      key_point: params[:key_point],
      question_id: params[:question_id],
      video_id: params[:video_id]
    )

    render json: { success: true }
  end

  def show
    @snapshot = Snapshot.find(params[:id])
    render json: { success: true, data: @snapshot } and return
  end

  def destroy
    snapshot = Snapshot.find(params[:id])
    snapshot.delete_tags
    snapshot.destroy
    redirect_to controller: "admin/videos", action: :show, id: params[:video_id] and return
  end
end
