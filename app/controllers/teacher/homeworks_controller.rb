# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  def index
    @homeworks = current_user.homeworks.desc(:created_at)
  end

  def show
    @homework = Homework.find(params[:id])
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
    document = Document.new
    document.document = params[:file]
    document.store_document!
    document.name = params[:file].original_filename
    homework = document.parse
    current_user.homeworks << homework
    redirect_to action: :show, id: homework.id.to_s
  end

  def replace
    homework = Homework.find(params[:id])
    document = Document.new
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

  def get_share
    homework = Homework.find(params[:id])
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true, share_info: homework.get_share }
      end
    end
  end

  def set_share
    homework = Homework.find(params[:id])
    homework.set_share(params[:share_info])
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
