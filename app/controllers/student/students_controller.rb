# encoding: utf-8
class Student::StudentsController < Student::ApplicationController

  before_filter :require_student

  def info
    render json: { success: true, name: current_user.name, mobile: current_user.mobile, email: current_user.email} and return
  end

  def rename
    render json: current_user.rename(params[:name]) and return
  end

  def change_password
    render json: current_user.change_password(params[:password], params[:new_password]) and return
  end

  def change_email
    render json: current_user.change_email(params[:email]) and return
  end

  def change_mobile
    render json: current_user.change_mobile(params[:mobile]) and return
  end

  def verify_mobile
    render json: current_user.verify_mobile(params[:verify_code]) and return
  end
end
