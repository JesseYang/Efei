# encoding: utf-8
class Account::PasswordsController < Account::ApplicationController

  def create
    # find out the user
    u = User.find_by_email_mobile(params[:email_mobile])
    if u.blank?
      respond_to do |format|
        format.html do
          flash[:notice] = "帐号不存在"
          redirect_to action: :new and return
        end
        format.json do
          render json: ErrCode.ret_false(ErrCode::USER_NOT_EXIST) and return
        end
      end
    end
    if params[:email_mobile].is_mobile?
      # TODO: send verify code sms to the user
      u.send_reset_password_code
      respond_to do |format|
        format.html do
        end
        format.json do
          render json: { success: true } and return
        end
      end
    else
      # send an email to the user
      PasswordEmailWorker.perform_async(u.id.to_s)
      respond_to do |format|
        format.html do
          flash[:notice] = "重置密码邮件已发送，请查收"
          redirect_to new_account_session_path and return
        end
        format.json do
          render json: { success: true } and return
        end
      end
    end
  end

  def verify_code
    render json: ErrCode.ret_false(ErrCode::USER_NOT_EXIST) and return if params[:mobile].blank?
    u = User.where(mobile: params[:mobile]).first
    render json: ErrCode.ret_false(ErrCode::USER_NOT_EXIST) and return if u.blank?
    if u.reset_password_verify_code != params[:verify_code]
      render json: ErrCode.ret_false(ErrCode::WRONG_VERIFY_CODE) and return
    end
    render json: { success: true, reset_password_token: u.reset_password_token } and return
  end

  def new
  end

  def edit
    @key = params[:key]
  end

  def update
    if ["android", "ios"].include?(@client)
      retval = User.app_reset_password(params[:reset_password_token], params[:password])
      render json: retval and return
    else
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

  def change_password
    value = @current_user.change_password(params[:password], params[:new_password])
    value = { success: true } if value.nil?
    render json: value
  end
end
