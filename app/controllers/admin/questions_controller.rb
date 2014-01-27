# encoding: utf-8
class Admin::QuestionsController < Admin::ApplicationController
  def update
    question = Question.find(params[:id])
    question.update_attributes({
      content: params[:content],
      items: params[:items]
    })
    respond_to do |format|
      format.html
      format.json do
        render json: {
          success: true,
          content: question.content,
          items: question.items
        }
      end
    end
  end
end
