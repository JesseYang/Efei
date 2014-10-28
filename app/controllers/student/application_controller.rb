class Student::ApplicationController < ApplicationController
  layout 'layouts/student'

  def require_student
    if current_user.blank?
      render json: ErrCode.ret_false(ErrCode::REQUIRE_SIGNIN)
    end
  end
end
