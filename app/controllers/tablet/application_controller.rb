class Tablet::ApplicationController < ApplicationController
  layout 'layouts/student'
  before_filter :student_init

  def student_init
    refresh_session(params[:auth_key] || cookies[:auth_key])
  end

  def require_student
    if current_user.blank?
      respond_to do |format|
        format.json do
          render json: ErrCode.ret_false(ErrCode::REQUIRE_SIGNIN)
        end
        format.html do
          redirect_to '/login' and return
        end
      end
    end
    if current_user.teacher
      redirect_to "/redirect" and return
    end
  end

  def render_with_auth_key(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value
  end
end
