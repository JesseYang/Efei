# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  def index
    @privilege = { "拥有" => 1, "共享" => 2, "全部" => 3 }
    @subject = params[:subject] || current_user.subject
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
  end

  def settings
    @homework = Homework.find(params[:id])
    @tags = current_user.tags
    @default_tags = DefaultTag::TAG[@homework.subject]
  end

  def destroy
    @homework = Homework.find(params[:id])
    @homework.destroy
    flash[:notice] = "作业已删除"
    redirect_to action: :index
  end

  def export
    homework = Homework.find(params[:id])
    redirect_to URI.encode "/#{homework.export}"
  end

  def generate
    homework = Homework.find(params[:id])
    download_url = "#{Rails.application.config.word_host}/#{homework.generate}"
    redirect_to URI.encode download_url
  end

  def create
    document = Document.new
    document.document = params[:file]
    document.store_document!
    document.name = params[:file].original_filename
    homework = document.parse_homework(params[:subject].to_i)
    current_user.homeworks << homework
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
end
