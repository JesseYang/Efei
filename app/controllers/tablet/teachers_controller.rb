# encoding: utf-8
class Tablet::TeachersController < Tablet::ApplicationController

  def show
    teacher = Teacher.find(params[:id])
    render_with_auth_key({teacher: teacher}) and return
  end
end
