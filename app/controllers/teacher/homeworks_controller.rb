# encoding: utf-8
class Teacher::HomeworksController < Teacher::ApplicationController
  layout :resolve_layout
  before_filter :ensure_homework, only: [:show, :stat, :move, :settings, :set_tag, :delete, :export, :generate, :rename, :star]

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

  def workbook
  end

  ########################################################

  def show
  end

  def stat
    @classes = @current_user.classes.map do |e|
      [e.name.to_s, e.id.to_s]
    end
    @classes.insert(0, ["全体学生", "-1"])
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
    current_user.nodes << homework
    if current_user.folders.where(id: params[:folder_id]).first
      folder_id = params[:folder_id]
    else
      folder_id = current_user.root_folder.id
    end
    homework.update_attribute :parent_id, folder_id
    redirect_to action: :show, id: homework.id.to_s
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
