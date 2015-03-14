# encoding: utf-8
class Teacher::FeedbacksController < Teacher::ApplicationController

  def create
    current_user.create_question_feedback(params[:question_id])
    render_json
  end
end
