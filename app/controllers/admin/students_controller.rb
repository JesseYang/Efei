#encoding: utf-8
class Admin::StudentsController < Admin::ApplicationController

  def index
    @students = auto_paginate User.where(tablet: true)
  end

  def create
    flash[:notice] = "创建成功"
    redirect_to action: :index and return
  end

  def update
    @student = User.find(params[:id])
    flash[:notice] = "更新成功"
    redirect_to action: :index and return
  end

  def destroy
    @student = User.find(params[:id])
    @student.destroy
    flash[:notice] = "删除成功"
    redirect_to action: :index and return
  end
end
