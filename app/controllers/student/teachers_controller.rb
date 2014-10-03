# encoding: utf-8
class Student::TeachersController < Student::ApplicationController

  def create
    t = User.find(params[:id])
    t.add_to_default_class(current_user)
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end

  def destroy
    t = User.find(params[:id])
    t.remove_student(current_user)
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
