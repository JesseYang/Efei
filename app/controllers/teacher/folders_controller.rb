#encoding: utf-8
class Teacher::FoldersController < Teacher::ApplicationController

  before_filter :ensure_folder, only: [:chain]
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
    render_json({ tree: tree, root_folder_id: current_user.root_folder.id.to_s })
  end

  # ajax
  def create
    @folder = Folder.create_new(current_user, params[:name], params[:parent_id])
    @folder["id"] = @folder.id.to_s
    render_json({ folder: @folder })
  end


  # ajax
  def chain
    chain = @folder.ancestor_chain
    new_chain = (chain.map { |e| { id: e.id.to_s, name: e.name} } .flat_map { |x| [x, { separate: true }] }) [0..-2]
    render_json({ chain: new_chain })
  end
end
