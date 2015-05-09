class Account::SessionsController < Account::ApplicationController

  def new
    if current_user.try(:teacher)
      redirect_to teacher_nodes_path and return
    elsif current_user.present?
      redirect_to student_notes_path and return
    end
    @role = params[:role] || "teacher"
  end

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
        render json: retval.merge({ admin: false })
      end
    end
  end

  def tablet_login
    retval = User.tablet_login(params[:email_mobile].to_s, params[:password].to_s)
    render json: retval and return
  end

  def sign_out
    refresh_session(nil)
    redirect_to redirect_to_root(params[:role]) and return
  end
end
