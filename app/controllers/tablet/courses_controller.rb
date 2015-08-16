# encoding: utf-8
class Tablet::CoursesController < Tablet::ApplicationController

  def index
    courses = Course.all.where(ready: true).desc(:created_at).map do |c|
      c.info_for_tablet
    end
    render_with_auth_key({courses: courses}) and return
  end

  def show
  	c = Course.where(id: params[:id]).first
  	render_with_auth_key({course: c.info_for_tablet}) and return
  end

  def create
  	
  end
end
