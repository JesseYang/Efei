# encoding: utf-8
class Tablet::ActionLogsController < Tablet::ApplicationController

  def index
    @logs = ActionLog.all.asc(:log_id)
  end

  def create
    retval = ActionLog.batch_create(params[:logs])
    logger.info "AAAAAAAAAAAAAAAAAAA"
    logger.info retval.inspect
    logger.info "AAAAAAAAAAAAAAAAAAA"
    render json: { success: true, max_id: retval.max } and return
  end

  def clear
    ActionLog.destroy_all
    redirect_to action: :index and return
  end
end
