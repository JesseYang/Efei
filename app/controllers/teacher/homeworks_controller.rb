# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  before_filter :ensure_homework, only: [:show, :settings, :set_tag, :destroy, :export, :generate, :rename]

  def ensure_homework
    @homework = Homework.find(params[:id])
  end

  def index
    @subject = params[:subject] || current_user.subject
    @homeworks = current_user.homeworks
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
  end

  def settings
    @tags = current_user.tags
    @default_tags = DefaultTag::TAG[@homework.subject]
  end

  def set_tag_set
    @homework.update_attributes({tag_set: params[:tag_set]})
    render json: { success: true }
  end

  def destroy
    @homework.destroy
    flash[:notice] = "作业已删除"
    redirect_to action: :index
  end

  def export
    redirect_to URI.encode "/#{@homework.export}"
  end

  def generate
    download_url = "#{Rails.application.config.word_host}/#{@homework.generate}"
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
    @homework.update_attributes({name: params[:name]})
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
