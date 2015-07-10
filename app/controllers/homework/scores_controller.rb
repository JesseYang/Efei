# encoding: utf-8
class Homework::ScoresController < Homework::ApplicationController

  def destroy
    @exam = Exam.where(id: params[:exam_id]).first
    @score = Score.where(id: params[:id]).first
    @score.destroy if @score.present?
    flash[:notice] = "删除成功"
    redirect_to homework_exam_path(@exam) and return
  end
end
