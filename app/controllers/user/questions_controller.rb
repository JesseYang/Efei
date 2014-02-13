class User::QuestionsController < User::ApplicationController
  before_filter :require_sign_in, only: [:append_note, :append_print]

  def show
    @question = Question.find(params[:id])
  end

  def similar
    q = Question.find(params[:id])
    q_ids = q.group.questions.map { |e| e.id.to_s }
    q_ids.delete(q.id.to_s)
    similar_questions = q_ids.map { |e| Question.find(e) }
    render partial: "user/questions/similar_questions", locals: { questions: similar_questions} and return
  end

  def append_note
    current_user.add_question_to_note(params[:id])
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end

  def append_paper
    current_user.add_question_to_paper(params[:id])
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
