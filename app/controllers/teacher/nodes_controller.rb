#encoding: utf-8
class Teacher::NodesController < Teacher::ApplicationController

  before_filter :ensure_node, only: [:list_children, :get_folder_id, :rename, :delete, :move, :star]
  def ensure_node
    begin
      @node = Node.find(params[:id])
    rescue
      render_json ErrCode.ret_false(ErrCode::NODE_NOT_EXIST)  and return
    end
  end

  def index
    @title = "文件夹"
    @type = params[:type].blank? ? "folder" : params[:type]
    @root_folder_id = current_user.root_folder.id
    if !%w{folder recent trash search all_homeworks all_slides all_shares starred workbook}.include?(@type)
      redirect_to teacher_nodes_path(folder_id: @root_folder_id, type: "folder") and return
    end

    case @type
    when "folder"
      @folder_id = params[:folder_id]
      if current_user.folders.where(id: @folder_id).first.nil?
        redirect_to teacher_nodes_path(folder_id: current_user.root_folder.id, type: "folder") and return
      end
      @root_folder = current_user.root_folder
    when "recent"
    when "trash"
    when "search"
      if params[:keyword].blank?
        redirect_to teacher_nodes_path(folder_id: @root_folder_id, type: "folder") and return
      end
    when "all_homeworks"
    when "all_slides"
    when "all_shares"
    when "starred"
    when "workbook"
    end
  end

  def get_folder_id
    render_json({ folder_id: @node.parent_id.to_s })
  end

  # ajax
  def rename
    @node.update_attribute(:name, params[:name])
    render_json
  end

  # ajax
  def create
    @folder = Folder.create_new(current_user, params[:name], params[:parent_id])
    @folder["id"] = @folder.id.to_s
    render_json({ folder: @folder })
  end

  # ajax
  def delete
    @node.trash
    render_json
  end

  def destroy
    @node = current_user.nodes.trashed.find(params[:id])
    @node.destroy
    render_json
  end

  # ajax
  def list_children
    @nodes = @node.list_children
    render_json({ nodes: @nodes })
  end

  # ajax
  def move
    begin
      des_folder = params[:des_folder_id] == "root" ? current_user.root_folder : current_user.folders.find(params[:des_folder_id])
      @node.update_attribute :parent_id, des_folder.id
      render_json
    rescue
      render_json ErrCode.ret_false(ErrCode::FOLDER_NOT_EXIST)
    end
  end

  # ajax
  def trash
    @nodes = current_user.nodes.list_trash
    render_json({ nodes: @nodes })
  end

  def all_shares
    @nodes = current_user.nodes.list_shares
    render_json({ nodes: @nodes })
  end

  def starred
    @nodes = current_user.nodes.list_starred
    render_json({ nodes: @nodes })
  end

  def star
    params[:add].to_s == "true" ? @node.star : @node.unstar
    render_json
  end

  def recent
    @nodes = current_user.nodes.list_recent
    render_json({ nodes: @nodes })
  end

  def all_homeworks
    @nodes = current_user.nodes.list_homeworks
    render_json({ nodes: @nodes })
  end

  def all_slides
    @nodes = current_user.nodes.list_slides
    render_json({ nodes: @nodes })
  end

  def workbook
    render_json({ nodes: [ ] })
  end

  # ajax
  def search
    @nodes = current_user.nodes.search(params[:keyword])
    render_json({ nodes: @nodes })
  end

  # ajax
  def recover
    begin
      node = current_user.nodes.trashed.find(params[:id])
      node.recover
      if node.parent.blank?
        node.update_attribute :parent_id, @current_user.root_folder.id
      end
      render_json({ parent_id: node.parent_id.to_s }) and return
    rescue
      render_json ErrCode.ret_false(ErrCode::NODE_NOT_EXIST) and return
    end
  end
end
