# encoding: utf-8
class Homework::ScoresController < Homework::ApplicationController

  def update
    @exam = Exam.where(id: params[:exam_id]).first
    @score = Score.where(id: params[:id]).first
    @score.update_score(params[:score].to_i)
    render json: { success: true } and return
  end

  def destroy
    @exam = Exam.where(id: params[:exam_id]).first
    @score = Score.where(id: params[:id]).first
    @score.destroy if @score.present?
    flash[:notice] = "删除成功"
    redirect_to homework_exam_path(@exam) and return
  end
end
