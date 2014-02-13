# encoding: utf-8
class User::PapersController < User::ApplicationController
  before_filter :require_sign_in

  def index
    @papers = current_user.papers.not_cur
  end

  def destroy
    paper = Paper.find(params[:id])
    paper.destroy
    redirect_to action: :current and return
  end

  def show
    @paper = current_user.papers.find(params[:id])
    @questions = (@paper.question_ids.map { |e| Question.find(e) }).select { |e| e.present? }
  end

  def current
    @paper = current_user.papers.cur.first || current_user.papers.create
    @questions = (@paper.question_ids.map { |e| Question.find(e) }).select { |e| e.present? }
  end

  def print
    paper = Paper.find(params[:id])
    redirect_to "/#{paper.print}"
  end

  def archive
    # save the paper as an archived one and clear the current paper
    @paper = Paper.find(params[:id])
    @paper.archive
    flash[:notice] = "试卷已归档"
    redirect_to action: :index
  end

  def rename
    paper = Paper.find(params[:id])
    paper.name = params[:name]
    paper.save
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
