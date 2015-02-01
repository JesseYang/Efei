class Account::RegistrationsController < Account::ApplicationController
  def create
    retval = User.create_new_user(params[:invite_code], params[:email_mobile].to_s, params[:password], params[:name], params[:role], params[:subject])
    refresh_session retval[:auth_key] if retval[:success]
    respond_to do |format|
      format.html
      format.json do
        render json: retval
      end
    end
  end

  def reset_email
    retval = User.verify_email(params[:key])
    render text: retval and return
  end
end
