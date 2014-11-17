#encoding: utf-8
class Teacher::FoldersController < Teacher::ApplicationController

  before_filter :ensure_folder, only: [:rename, :destroy, :move, :list, :recover]
  def ensure_folder
    begin
      @folder = Folder.find(params[:id])
    rescue
      render_json ErrCode.ret_false(ErrCode::FOLDER_NOT_EXIST) and return
    end
  end

  # ajax
  def index
    tree = Folder.folder_tree(current_user)
    render_json({ tree: tree, root_folder_id: current_user.root_folder.id })
  end

  # ajax
  def rename
    @folder.update_attribute(:name, params[:name])
    render_json
  end

  # ajax
  def create
    @folder = Folder.create_new(current_user, params[:name], params[:parent_id])
    render_json({ folder: @folder })
  end

  # ajax
  def destroy
    @folder.trash
    render_json
  end

  # ajax
  def move
    begin
      @folder.move_to(current_user, params[:des_folder_id])
      render_json
    rescue
      render_json ErrCode.ret_false(ErrCode::FOLDER_NOT_EXIST)
    end
  end

  # ajax
  def list
    nodes = @folder.list_nodes
    render_json({ nodes: nodes })
  end

  # ajax
  def recover
    begin
      folder = current_user.folders.trashed.find(params[:id])
      folder.recover
      render_json({ folder: folder })
    rescue
      render_json ErrCode.ret_false(ErrCode::FOLDER_NOT_EXIST)
    end
  end
end
