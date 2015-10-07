#encoding: utf-8
class Admin::ClientsController < Admin::ApplicationController

  def index
    @clients = User.where(is_client: true)
    if params[:keyword].present?
      @clients = @clients.any_of({city: /#{params[:keyword]}/}, {client_name: /#{params[:keyword]}/}, {name: /#{params[:keyword]}/}, {email: /#{params[:keyword]}/}, {mobile: /#{params[:keyword]}/})
    end
    @clients = auto_paginate @clients
  end

  def create
    new_client = User.create_client(params[:client])
    case new_client
    when ErrCode::CLIENT_NAME_EXIST
      flash[:notice] = "机构名称已存在"
    when ErrCode::EMAIL_EXIST
      flash[:notice] = "邮箱已存在"
    when ErrCode::MOBILE_EXIST
      flash[:notice] = "手机号已存在"
    else
      flash[:notice] = "创建成功"
      redirect_to admin_client_path(new_client) and return
    end
    redirect_to admin_clients_path and return
  end

  def show
    @client = User.find(params[:id])
  end

  def update
    @client = User.find(params[:id])
    @client.update_client(params[:client])
    flash[:notice] = "更新成功"
    redirect_to action: :index and return
  end

  def destroy
    @client = User.find(params[:id])
    @client.destroy
    flash[:notice] = "删除成功"
    redirect_to action: :index and return
  end

  def new
    @client = User.new
    @new = true
  end

  def edit
    @client = User.find(params[:id])
    render action: :new
  end

  def add_course
=begin
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    if !@student.student_local_courses.include?(@local_course)
      @student.student_local_courses << @local_course
    end
=end
    render json: { success: true }
  end

  def remove_course
=begin
    @student = User.find(params[:id])
    @local_course = LocalCourse.find(params[:local_course_id])
    @student.student_local_courses.delete(@local_course)
=end
    render json: { success: true }
  end
end
