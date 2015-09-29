# encoding: utf-8
class Tablet::ActionLogsController < Tablet::ApplicationController

  def create
    retval = ActionLog.batch_create(params[:logs])
    render json: { success: true, max_id: retval.max } and return
  end
end
