class Account::RegistrationsController < Account::ApplicationController

  def new
    if current_user.try(:teacher)
      redirect_to teacher_nodes_path and return
    elsif current_user.present?
      redirect_to student_notes_path and return
    end
    @role = params[:role] || "teacher"
  end

  def create
    retval = User.create_new_user(params[:invite_code], params[:email_mobile].to_s, params[:password], params[:name], params[:school_name], params[:role], params[:subject], params[:tablet])
    refresh_session retval[:auth_key] if retval[:success]
    respond_to do |format|
      format.html
      format.json do
        render json: retval
      end
    end
  end

  def reset_email
    key_prime = CGI::unescape(params[:key])
    @retval = User.verify_email(key_prime)
  end

  def finish
    if current_user.blank?
      render json: ErrCode.ret_false(ErrCode::USER_NOT_EXIST) and return
    else
      retval = current_user.tablet_student_finish_register(params[:real_name], params[:city], params[:school], params[:grade])
      render_with_auth_key and return
    end
  end
end
