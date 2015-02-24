# encoding: utf-8
class Teacher::PapersController < Teacher::ApplicationController

  def index
    @papers = Homework.where(type: "paper")
  end

  def show
    @paper = Homework.find(params[:id])
  end
end
