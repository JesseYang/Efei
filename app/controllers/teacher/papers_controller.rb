# encoding: utf-8
class Teacher::PapersController < Teacher::ApplicationController

  def index
    @papers = Homework.where(type: "paper").desc(:name)
  end

  def show
    @paper = Homework.find(params[:id])
  end
end
