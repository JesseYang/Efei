# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  def index
    @privilege = { "拥有" => 1, "共享" => 2, "全部" => 3 }
    if params[:privilege].to_i == 1
      @homeworks = current_user.homeworks
    elsif params[:privilege].to_i == 2
      @homeworks = current_user.shared_homeworks
    else
      @homeworks = Homework.any_in(id: (current_user.homeworks+current_user.shared_homeworks).map { |r| r.id })
    end
    if params[:subject].to_i != 0
      @homeworks = @homeworks.where(subject: params[:subject].to_i)
    end
    if params[:keyword].present?
      @homeworks = @homeworks.where(name: /#{params[:keyword]}/)
    end
    if params[:sort].present?
      @homeworks = params[:dir] == "true" ? @homeworks.desc(params[:sort].to_sym) : @homeworks.asc(params[:sort].to_sym)
    else
      params[:sort] = "created_at"
      params[:dir] = "true"
      @homeworks = @homeworks.desc(:created_at)
    end
    @homeworks = auto_paginate @homeworks
  end

  def show
    @homework = Homework.find(params[:id])
    @colleagues = current_user.colleagues
    @colleague_ids = @colleagues.map { |e| e.id.to_s }
    @visitor_ids = @homework.visitors.map { |e| e.id.to_s }
  end

  def destroy
    @homework = Homework.find(params[:id])
    @homework.destroy
    redirect_to action: :index
  end

  def export
    homework = Homework.find(params[:id])
    redirect_to URI.encode "/#{homework.export}"
  end

  def generate
    homework = Homework.find(params[:id])
    redirect_to URI.encode "/#{homework.generate}"
  end

  def create
    document = Document.new(params[:subject])
    document.document = params[:file]
    document.store_document!
    document.name = params[:file].original_filename
    homework = document.parse
    current_user.homeworks << homework
    redirect_to action: :show, id: homework.id.to_s
  end

  def replace
    homework = Homework.find(params[:id])
    document = Document.new(homework.subject)
    document.document = params[:file]
    document.store_document!
    document.name = params[:file].original_filename
    document.parse(homework)
    redirect_to action: :show, id: homework.id.to_s
  end

  def rename
    homework = Homework.find(params[:id])
    homework.name = params[:name]
    homework.save
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end

  def destroy
    homework = Homework.find(params[:id])
    homework.destroy
    redirect_to action: :index
  end

  def share_all
    homework = Homework.find(params[:id])
    if params[:share]
      homework.visitors = current_user.colleagues
      homework.save
    else
      homework.visitors.clear
    end
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end

  def share
    homework = Homework.find(params[:id])
    teacher = User.find(params[:teacher_id])
    if params[:share]
      homework.visitors << teacher
    else
      homework.visitors.delete(teacher)
    end
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
