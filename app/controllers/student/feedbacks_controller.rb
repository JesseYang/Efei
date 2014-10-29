# encoding: utf-8
class Student::FeedbacksController < Student::ApplicationController

  before_filter :require_student

  def create
    current_user.create_feedback(params[:content])
    render_with_auth_key
  end
end
