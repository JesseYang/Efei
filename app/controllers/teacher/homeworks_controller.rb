# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  before_filter :ensure_homework, only: [:show, :settings, :set_tag, :delete, :export, :generate, :rename]

  def ensure_homework
    begin
      @homework = Homework.find(params[:id])
    rescue
      respond_to do |format|
        format.html
        format.json do
          render_json ErrCode.ret_false(ErrCode::HOMEWORK_NOT_EXIST) and return
        end
      end
    end
  end

  ########### list folders or documents #################

  # params:
  #   parent_id
  #   type: folder, document, or both
  #   subject
  def index
    @root_folder = current_user.root_folder
    @folder_id = params[:folder_id]
    if params[:search].blank?
      # folder navigation
      @folder = current_user.folders.where(id: params[:folder_id]).first || current_user.root_folder
      @folder_chain = @folder.ancestor_chain
    else
      # search result
      @subject = params[:subject] || current_user.subject
      @homeworks = current_user.homeworks
      if params[:subject].to_i != 0
        @homeworks = @homeworks.where(subject: params[:subject].to_i)
      end
      if params[:keyword].present?
        @homeworks = @homeworks.where(name: /#{params[:keyword]}/)
      end
    end
  end

  def trash
    @nodes = current_user.folders.trashed + current_user.homeworks.trashed
  end

  def workbook
  end

  def recent_used
    @nodes = current_user.homeworks.desc(:updated_at).limit(20)
  end

  ########################################################

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

  def delete
    @homework.trash
    flash[:notice] = "作业已删除"
    redirect_to action: :index
  end

  def destroy
    @homework = current_user.homeworks.trashed.find(params[:id])
    @homework.destroy
  end

  def recover
    @homework = current_user.homeworks.trashed.find(params[:id])
    @homework.recover
  end

  def export
    redirect_to URI.encode "/#{@homework.export}"
  end

  def generate
    download_url = "#{Rails.application.config.word_host}/#{@homework.generate}"
    redirect_to URI.encode download_url
  end

  # ajax
  def create
    document = Document.new
    document.document = params[:file]
    document.store_document!
    document.name = params[:file].original_filename
    homework = document.parse_homework(params[:subject].to_i)
    current_user.homeworks << homework
    if current_user.folders.where(id: params[:folder_id]).first
      folder_id = params[:folder_id]
    else
      folder_id = current_user.root_folder.id
    end
    homework.update_attribute :folder_id, folder_id
    redirect_to action: :show, id: homework.id.to_s
  end

  # ajax
  def rename
    @homework.update_attribute :name, params[:name]
    render_json
  end
end
