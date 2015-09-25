# encoding: utf-8
class Tablet::SummariesController < Tablet::ApplicationController
  # params[:auth_key]
  # params[:snapshot_id]
  # params[:checked]
  def create
    student = User.find_by_auth_key(params[:auth_key])
    snapshot = Homework.find(params[:snapshot_id])
    Summary.create_new(student, snapshot, params[:checked])
    render json: { success: true } and return
  end
end
