# encoding: utf-8
class Client::CoachesController < Client::ApplicationController
  skip_before_filter :client_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/client/coaches") and return
  end

  def index
    @return_path = main_page_client_users_path
    @title = "教师列表"
    @coaches = @current_user.client_coaches
  end

  def list
    @coaches = @current_user.client_coaches
    render json: {success: true, data: @coaches.map { |e| e.name }} and return
  end

  def new
    @title = "创建教师"
  end

  def create
    c = User.create_coach(params[:coach].merge({"client_id" => @current_user.id.to_s}))
    redirect_to client_coaches_path and return
  end

  def show
  end

  def students
    
  end
end
