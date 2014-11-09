# encoding: utf-8
class Student::TeachersController < Student::ApplicationController

  before_filter :require_student

  def index
    if params[:scope].to_i == 1
      retval = current_user.list_my_teachers
      render_with_auth_key retval
    else
      retval = User.search_teachers(params[:subject].to_i, params[:name])
      render_with_auth_key retval
    end
  end

  def create
    t = User.where(id: params[:teacher_id]).first
    render_with_auth_key ErrCode.ret_false(ErrCode::TEACHER_NOT_EXIST) and return if t.blank?
    retval = t.add_to_class(params[:class_id], current_user)
    render_with_auth_key retval
  end

  def destroy
    t = User.find(params[:id])
    t.remove_student(current_user)
    render_with_auth_key
  end
end
