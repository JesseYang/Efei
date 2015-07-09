# encoding: utf-8
class Homework::KlassesController < Homework::ApplicationController
  skip_before_filter :homework_init, only: :redirect

  def redirect
    redirect_to Platform.generate_authorize_link(Rails.application.config.server_host + "/homework/klasses") and return
  end

  def index
    @school = @current_user.school
    @klasses = @school.klasses.asc(:name)
    if @klasses.blank?
      render action: :list and return
    end
    @title = "我的班级"
  end

  def list
    @school = @current_user.school
    @klasses = @school.klasses.asc(:name)
    @current_klasses = @current_user.classes
    @title = "班级选择"
  end

  def create
    klass_id_ary = params[:klass_id_str].split(',')
    @current_user.set_classes(klass_id_ary)
    render json: { success: true } and return
  end
end
