# encoding: utf-8
class Client::CoursesController < Client::ApplicationController
  skip_before_filter :client_init, only: :redirect

  def index
    @courses = Course.all
  end

  def list
    @courses = Course.all
    render json: {success: true, data: @courses.map { |e| e.name }} and return
  end
end
