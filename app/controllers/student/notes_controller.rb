class Student::NotesController < Student::ApplicationController
  before_filter :require_sign_in

  def index
    @questions = current_user.note.map { |e| Question.find(e["id"]) }
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
