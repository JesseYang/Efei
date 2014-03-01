# encoding: utf-8
class Admin::QuestionsController < Admin::ApplicationController
  def update
    question = Question.find(params[:id])
    question.update_content(params[:content])
    question.update_items(params[:items])
    question.update_attributes(answer: params[:answer].to_i)
    respond_to do |format|
      format.html
      format.json do
        render json: {
          success: true,
          content_for_show: question.content.render_question,
          content_for_edit: question.content.render_question_for_edit,
          items_for_show: question.items.map { |e| e.render_question },
          items_for_edit: question.items.map { |e| e.render_question_for_edit },
          answer: question.answer
        }
      end
    end
  end
end
