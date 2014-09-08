# encoding: utf-8
class Student::QuestionsController < Student::ApplicationController
  before_filter :require_sign_in, only: [:append_note, :append_print]

  def show
    if current_user.present?
      note = current_user.notes.where(question_id: params[:id]).first
      redirect_to controller: "student/notes", action: :show, id: note.id.to_s and return if note.present?
    end
    @question = Question.find(params[:id])
    @similar_questions_length = 0
    @note_type = { "请选择" => 0, "不懂" => 1, "不会" => 2, "不对" => 3 }
  end

  def append_note
    note_id = current_user.add_question_to_note(params[:id], params[:summary], params[:note_type].to_i, params[:topics])
    flash[:notice] = "保存成功"
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true, note_id: note_id }
      end
    end
  end

  def exercise
    if params[:type] == "group"
      q = Question.find(params[:question_id])
      @questions = q.group.questions
    elsif params[:type] = "note"
      @questions = current_user.note.map { |e| Question.find(e["id"]) }
    else
      @questions = []
    end
  end

  def answer
    questions = params[:qid_ary].map { |e| Question.find(e) }
    result = { detail: [], stats: {right: 0, wrong: 0} }
    questions.each_with_index do |q, index|
      result[:detail] << {
        qid: q.id.to_s,
        answer: q.answer.to_i,
        user_answer: params[:answer_ary][index].to_i,
        note: current_user && current_user.note.map { |e| e["id"] } .include?(q.id.to_s)
      }
      if q.answer.to_i == params[:answer_ary][index].to_i
        result[:stats][:right] += 1
      else
        result[:stats][:wrong] += 1
      end
    end
    respond_to do |format|
      format.html
      format.json do
        render json: { result: result }
      end
    end
  end

  def check_note
    qids = params[:qids].split(',')
    result = qids.map do |e|
      current_user && current_user.note.map { |ee| ee["id"] } .include?(e)
    end
    respond_to do |format|
      format.html
      format.json do
        render json: { result: result }
      end
    end
  end
end
