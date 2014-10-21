class WelcomeController < ApplicationController
  layout 'layouts/index'
  def index
    flash[:notice] = params[:notice]
    if current_user.try(:school_admin)
      redirect_to school_admin_teachers_path and return
    elsif current_user.try(:teacher)
      redirect_to teacher_homeworks_path and return
    elsif current_user.present?
      redirect_to student_notes_path and return
    end
  end
end
