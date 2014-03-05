# encoding: utf-8
class Admin::QuestionsController < Admin::ApplicationController
  def update
    @question = Question.find(params[:id])
    @question.update_content(params[:question_content], params[:question_answer])
    if @question.type == "choice"
      @question.update_items(params[:items])
      @question.update_attributes(answer: params[:answer].to_i)
    end
    respond_to do |format|
      format.html
      format.json do
        render json: {
          success: true,
          content_for_show: render_to_string(:partial => 'partials/question_content', :layout => false, :locals => {:content => @question.content}),
          content_for_edit: @question.content.render_question_for_edit,
          answer_for_show: render_to_string(:partial => 'partials/question_content', :layout => false, :locals => {:content => @question.answer_content}),
          answer_for_edit: @question.answer_content.render_question_for_edit,
          items_for_show: @question.items.map { |e| e.render_question },
          items_for_edit: @question.items.map { |e| e.render_question_for_edit },
          answer: @question.answer
        }
      end
    end
  end
end
