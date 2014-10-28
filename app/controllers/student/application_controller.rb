class Student::ApplicationController < ApplicationController
  layout 'layouts/student'

  def require_student
    if current_user.blank?
      render json: ErrCode.ret_false(ErrCode::REQUIRE_SIGNIN)
    end
  end

  def render_with_auth_key(value)
    value[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: value and return
  end
end
