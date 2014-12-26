# encoding: utf-8
class Teacher::SlidesController < Teacher::ApplicationController
  layout :resolve_layout
  before_filter :ensure_slide, only: [:show, :move, :settings, :set_tag, :delete, :export, :generate, :rename, :star]

  def ensure_slide
    begin
      @slide = Slide.find(params[:id])
    rescue
      respond_to do |format|
        format.html
        format.json do
          render_json ErrCode.ret_false(ErrCode::SLIDES_NOT_EXIST) and return
        end
      end
    end
  end

  def show
  end

  def rename
    @slide.update_attribute :name, params[:name]
    render_json
  end

  # ajax
  def create
    begin
      document = Document.new
      document.document = params[:slide_file]
      document.store_document!
      document.name = params[:slide_file].original_filename
      slide = document.parse_slide(params[:subject].to_i)
      current_user.nodes << slide
      if current_user.folders.where(id: params[:folder_id]).first
        folder_id = params[:folder_id]
      else
        folder_id = current_user.root_folder.id
      end
      slide.update_attribute :parent_id, folder_id
      redirect_to action: :show, id: slide.id.to_s
    rescue Exception => e
      if e.message == "wrong filetype"
        flash[:error] = "文件格式错误或者文件损坏，请上传ppt或者pptx格式文件"
        redirect_to teacher_nodes_path
      end
    end
  end

  def resolve_layout
    case action_name
    when "show"
      "layouts/slide"
    else
      "layouts/teacher"
    end
  end
end
