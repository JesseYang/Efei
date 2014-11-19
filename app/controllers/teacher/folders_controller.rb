#encoding: utf-8
class Teacher::FoldersController < Teacher::ApplicationController

  before_filter :ensure_folder, only: [:rename, :delete, :move, :list, :chain]
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
  def delete
    @folder.trash
    render_json
  end

  def destroy
    @folder = current_user.folders.trashed.find(params[:id])
    @folder.destroy
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
  def trash
    @nodes = current_user.folders.list_trash + current_user.homeworks.list_trash
    render_json({ nodes: @nodes })
  end

  # ajax
  def search
    @nodes = current_user.folders.search(params[:keyword]) + current_user.homeworks.search(params[:keyword])
    render_json({ nodes: @nodes })
  end

  # ajax
  def chain
    chain = @folder.ancestor_chain
    new_chain = (chain.map { |e| { id: e.id, name: e.name} } .flat_map { |x| [x, { separate: true }] }) [0..-2]
    render_json({ chain: new_chain })
  end

  # ajax
  def recover
    begin
      folder = current_user.folders.trashed.find(params[:id])
      folder.recover
      if folder.parent.blank?
        folder.update_attribute :parent_id, @current_user.root_folder.id
      end
      render_json({ parent_id: folder.parent_id }) and return
    rescue
      render_json ErrCode.ret_false(ErrCode::FOLDER_NOT_EXIST) and return
    end
  end
end
