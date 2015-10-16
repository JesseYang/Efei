#encoding: utf-8
class Admin::SnapshotsController < Admin::ApplicationController

  def create
    @video = Video.find(params[:video_id])
    s = Snapshot.create(
      time: params[:video_end].to_s == "true" ? -1 : params[:time].to_f,
      key_point: params[:key_point],
      question_id: params[:question_id],
      video_id: params[:video_id]
    )

    render json: { success: true }
  end

  def show
    @snapshot = Snapshot.find(params[:id])
    render json: { success: true, data: @snapshot.info_for_check } and return
  end

  def update
    @snapshot = Snapshot.find(params[:id])
    @question = Question.find(params[:question_id])
    @snapshot.question = @question
    params[:key_point].each_with_index do |desc, i|
      @snapshot.key_point[i]["desc"] = desc
    end
    if params[:video_end].to_s == "true"
      @snapshot.time = -1
    end
    @snapshot.save
    render json: { success: true }
  end

  def destroy
    snapshot = Snapshot.find(params[:id])
    snapshot.delete_tags
    snapshot.destroy
    redirect_to controller: "admin/videos", action: :show, id: params[:video_id] and return
  end
end
