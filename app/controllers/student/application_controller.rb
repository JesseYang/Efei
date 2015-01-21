class Student::ApplicationController < ApplicationController
  layout 'layouts/student'
  before_filter :student_init

  def student_init
    refresh_session(params[:auth_key])
  end

  def require_student
    if current_user.blank?
      render json: ErrCode.ret_false(ErrCode::REQUIRE_SIGNIN)
    end
  end

  def render_with_auth_key(value = nil)
    value = { success: true } if value.nil?
    value[:success] = true if value[:success].nil?
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value
  end
end
