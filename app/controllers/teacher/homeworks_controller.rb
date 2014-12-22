# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  layout :resolve_layout
  before_filter :ensure_homework, only: [:get_folder_id, :show, :stat, :move, :settings, :set_tag, :delete, :export, :generate, :rename, :star]

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
  def index
    @type = params[:type].blank? ? "folder" : params[:type]
    @root_folder_id = current_user.root_folder.id
    if !%w{folder recent trash search all starred workbook}.include?(@type)
      redirect_to action: :index, folder_id: @root_folder_id, type: "folder" and return
    end

    case @type
    when "folder"
      @folder_id = params[:folder_id]
      if current_user.folders.where(id: @folder_id).first.nil?
        redirect_to action: :index, folder_id: current_user.root_folder.id, type: "folder" and return
      end
      @root_folder = current_user.root_folder
    when "recent"
    when "trash"
    when "search"
      if params[:keyword].blank?
        redirect_to action: index, folder_id: @root_folder_id, type: "folder" and return
      end
    when "all"
    when "starred"
    when "workbook"
    end
  end

  def workbook
  end

  def recent
    @nodes = current_user.homeworks.list_recent
    render_json({ nodes: @nodes })
  end

  def all
    @nodes = current_user.homeworks.list_all
    render_json({ nodes: @nodes })
  end

  ########################################################

  def get_folder_id
    render_json({ folder_id: @homework.folder_id })
  end

  def show
  end

  def stat
    @classes = @current_user.classes.map do |e|
      [e.name.to_s, e.id.to_s]
    end
    @classes.insert(0, ["全体学生", "-1"])
  end

  def move
    begin
      folder = current_user.folders.find(params[:folder_id])
      @homework.update_attribute :folder_id, params[:folder_id]
      render_json
    rescue
      render_json ErrCode.ret_false(ErrCode::FOLDER_NOT_EXIST)
    end
  end

  def settings
    @type = %w{basic export tag} .include?(params[:type]) ? params[:type] : "basic"
    case @type
    when "basic"
    when "export"
    when "tag"
      @tag_sets = current_user.tag_sets
    end
  end

  def set_tag_set
    @homework.update_attributes({tag_set: params[:tag_set]})
    render json: { success: true }
  end

  def delete
    @homework.trash
    render_json
  end

  def destroy
    @homework = current_user.homeworks.trashed.find(params[:id])
    @homework.destroy
    render_json
  end

  def recover
    @homework = current_user.homeworks.trashed.find(params[:id])
    @homework.recover
    if @homework.folder.blank?
      @homework.update_attribute :folder_id, @current_user.root_folder.id
    end
    render_json({ parent_id: @homework.folder_id }) and return
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
    document.document = params[:homework_file]
    document.store_document!
    document.name = params[:homework_file].original_filename
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

  def star
    params[:add].to_s == "true" ? @homework.star : @homework.unstar
    render_json
  end

  def resolve_layout
    case action_name
    when "show", "stat", "settings"
      "layouts/homework"
    else
      "layouts/teacher"
    end
  end
end
