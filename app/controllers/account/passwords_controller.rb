# encoding: utf-8
class Account::PasswordsController < ApplicationController

  def create
    # find out the user
    u = User.where(email: params[:email]).first
    if u.blank?
      flash[:notice] = "邮箱帐号不存在"
      redirect_to action: :new and return
    end
    # send an email to the user
    PasswordEmailWorker.perform_async(u)
    flash[:notice] = "重置密码邮件已发送，请查收"
    redirect_to new_account_session_path and return
  end

  def new
  end

  def edit
    @key = params[:key]
  end

  def update
    # render :text => params and return
    if params[:password] != params[:password_confirmation]
      flash[:notice] = "密码与确认不一致"
      redirect_to action: :edit, key: params[:key] and return
    end
    retval = User.reset_password(params[:key], params[:password])
    refresh_session retval[:auth_key] if retval[:success]
    flash[:notice] = "重置密码成功，已自动登录"
    redirect_to redirect_to_root and return
  end
end
