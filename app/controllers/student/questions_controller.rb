# encoding: utf-8
class Student::QuestionsController < Student::ApplicationController
  before_filter :require_student, only: [:create, :batch]

  def show
    q = Question.where(id: params[:id]).first
    render_with_auth_key ErrCode.ret_false(ErrCode::QUESTION_NOT_EXIST) and return if q.nil?
    if current_user.present?
      note = current_user.notes.where(question_id: params[:id]).first
      render_with_auth_key({ success: true, note_id: note.id.to_s }) and return if note.present?
    end
    render_with_auth_key q.info_for_student and return
  end
end
