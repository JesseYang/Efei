# encoding: utf-8
class Tablet::TeachersController < Tablet::ApplicationController

  def index
    courses = Course.all.where(ready: true)
    teachers = courses.map { |c| c.teacher } .uniq .map do |t|
      t.info_for_tablet
    end
    render_with_auth_key({teachers: teachers}) and return
  end

  def show
    teacher = Teacher.find(params[:id])
    render_with_auth_key({teacher: teacher}) and return
  end
end
