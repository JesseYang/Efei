# encoding: utf-8
class Student::QuestionsController < Student::ApplicationController
  layout :resolve_layout

  def show
    @q = Question.where(id: params[:id]).first
    @h = Homework.where(id: params[:hid]).first || @q.homeworks.first
    if @q.nil? || @h.nil?
      respond_to do |format|
        format.json do
          render_with_auth_key ErrCode.ret_false(ErrCode::QUESTION_NOT_EXIST) and return
        end
        format.html do
          return
        end
      end
    end
    if current_user.present?
      note = current_user.notes.where(question_id: params[:id]).first
      render_with_auth_key({ success: true, note_id: note.id.to_s }) and return if note.present?
    end
    respond_to do |format|
      format.json do
        render_with_auth_key @q.info_for_student(@h) and return
      end
      format.html do
        return
      end
    end
  end

  def resolve_layout
    case action_name
    when "show"
      "layouts/application"
    else
      "layouts/student"
    end
  end
end
