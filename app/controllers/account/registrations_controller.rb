class Account::RegistrationsController < ApplicationController
  def create
    retval = User.create_new_user(params[:email_mobile].to_s, params[:password], params[:name])
    refresh_session retval[:auth_key] if retval[:success]
    respond_to do |format|
      format.html
      format.json do
        render json: retval
      end
    end
  end
end
