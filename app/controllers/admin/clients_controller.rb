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

  def open_course
    @client = User.find(params[:id])
    @course = Course.find(params[:course_id])
    if !@client.client_courses.include?(@course)
      @client.client_courses << @course
    end
    flash[:notice] = "成功开通课程"
    redirect_to admin_client_path(@client) and return
  end

  def close_course
    @client = User.find(params[:id])
    @course = Course.find(params[:course_id])
    @client.client_courses.delete(@course)
    flash[:notice] = "课程已关闭"
    redirect_to admin_client_path(@client) and return
  end
end
