# encoding: utf-8
class Tablet::CoursesController < Tablet::ApplicationController

  def index
    courses = Course.all.where(ready: true).map do |c|
      c.info_for_tablet
    end
    render_with_auth_key({courses: courses}) and return
  end
end
