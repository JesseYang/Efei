# encoding: utf-8
class Student::StudentsController < Student::ApplicationController

  before_filter :require_student

  def info
    render_with_auth_key({success: true, name: current_user.name, mobile: current_user.mobile, email: current_user.email})
  end

  def rename
    render_with_auth_key current_user.rename(params[:name])
  end

  def change_password
    render_with_auth_key current_user.change_password(params[:password], params[:new_password])
  end

  def change_email
    render_with_auth_key current_user.change_email(params[:email])
  end

  def change_mobile
    render_with_auth_key current_user.change_mobile(params[:mobile])
  end

  def verify_mobile
    render_with_auth_key current_user.verify_mobile(params[:verify_code])
  end
end
