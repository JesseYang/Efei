# encoding: utf-8
class Student::NotesController < Student::ApplicationController
  before_filter :require_sign_in

  def index
    @questions = current_user.list_question_in_note(params[:subject].to_i, Time.now.to_i - params[:period].to_i)
  end

  def show
    @note = current_user.notes.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])
    if current_user.note_ids.include?(params[:id])
      @note.update_note(params[:summary], params[:note_type], params[:topics])
    else
      @note = Note.create_new(@note.question_id.to_s, params[:summary], params[:note_type], params[:topics])
      current_user.notes << @note
    end
    flash[:notice] = "更新成功"
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true, note_id: @note.id.to_s }
      end
    end
  end

  def destroy
    current_user.rm_question_from_note(params[:id])
    redirect_to action: :index
  end

  def export
    file_path = current_user.export_note(
      params[:has_answer].to_s == "true",
      params[:send_email].to_s == "true",
      params[:email]
    )
    respond_to do |format|
      format.html
      format.json do
        render json: { file_path: file_path }
      end
    end
  end
end
