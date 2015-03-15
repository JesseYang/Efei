# encoding: utf-8
class Teacher::PapersController < Teacher::ApplicationController

  def index
    @papers = Homework.where(type: "paper").desc(:name)
  end

  def show
    @paper = Homework.find(params[:id])
  end

  def show_one
    @paper = Homework.find(params[:id])
  end

  def list
  	@papers = Homework.where(type: "paper", finished: true)
  	@papers = auto_paginate_ajax(@papers, params[:page] || 1, params[:per_page] || 10)
  	render_json({ papers: @papers }) and return
  end

  def modify
    hs = Homework.where(type: "paper", finished: true)
    hs.each do |h|
      h.paper_type = "高考真题"
      h.save
    end
    render text: "ok" and return
  end
end
