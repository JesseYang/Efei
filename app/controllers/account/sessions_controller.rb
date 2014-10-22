class Account::SessionsController < ApplicationController
  def create
    retval = User.login(params[:email_mobile].to_s, params[:password].to_s)
    refresh_session retval[:auth_key] if retval[:success]
    respond_to do |format|
      format.html do
        if retval[:success]
          redirect_to redirect_to_root and return
        else
          redirect_to new_account_session_path and return
        end
      end
      format.json do
        render json: retval
      end
    end
  end

  def sign_out
    refresh_session(nil)
    redirect_to redirect_to_root and return
  end
end
