# encoding: utf-8
class Client::CoursesController < Client::ApplicationController
  skip_before_filter :client_init, only: :redirect

  def index
    @return_path = main_page_client_users_path
    @title = "已开课程"
    @courses = @current_user.client_courses
  end

  def list
    @courses = @current_user.client_courses
    render json: {success: true, data: @courses.map { |e| e.name }} and return
  end
end
