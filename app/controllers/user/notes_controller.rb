class User::NotesController < User::ApplicationController
  before_filter :require_sign_in

  def index
    @questions = current_user.note.map { |e| Question.find(e["id"]) }
  end

  def destroy
    current_user.rm_question_from_note(params[:id])
    redirect_to action: :index
  end
end
