# encoding: utf-8
class Tablet::CoursesController < Tablet::ApplicationController

  before_filter :get_client, only: [:index, :show]

  def get_client
    if @current_user.is_client
      @client = @current_user
    elsif @current_user.coach
      @client = @current_user.coach_client
    else
      @client = @current_user.student_client
    end
  end

  def index
    courses = @client.client_courses.where(ready: true).desc(:created_at).map do |c|
      c.info_for_tablet
    end
    render_with_auth_key({courses: courses}) and return
  end

  def show
    c = @client.client_courses.where(id: params[:id]).first
    render_with_auth_key({course: c.info_for_tablet}) and return
  end

  def create
    
  end
end
