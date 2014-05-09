#encoding: utf-8
class Teacher::TeachersController < Teacher::ApplicationController

  # list colleagues
  def index
    @colleagues = current_user.school.teachers.where(subject: current_user.subject)
  end
end
