# encoding: utf-8
class Teacher::PapersController < Teacher::ApplicationController

  def index
    @papers = Homework.where(type: "paper").desc(:name)
  end

  def show
    @paper = Homework.find(params[:id])
    @title = @paper.name
    @questions = @paper.q_ids.map { |e| Question.find(e) }
  end

  def show_one
    @paper = Homework.find(params[:id])
  end

  def list
    @papers = Homework.where(type: "paper", finished: true)
    if params[:paper_year] != "0" && params[:paper_year] != ""
      @papers = @papers.where(year: params[:paper_year].to_i)
    end
    if params[:paper_province] != "0" && params[:paper_province] != ""
      @papers = @papers.where(province: params[:paper_province])
    end
    if params[:paper_type] != "0" && params[:paper_type] != ""
      @papers = @papers.where(paper_type: params[:paper_type])
    end
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
