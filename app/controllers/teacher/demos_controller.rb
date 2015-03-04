# encoding: utf-8
class Teacher::DemosController < Teacher::ApplicationController

  def index
    @question = Question.where(demo: true).first
  end

  def show
    @demo = Demo.where(order: params[:id].to_i).first
  end
end
