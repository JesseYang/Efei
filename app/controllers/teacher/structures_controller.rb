#encoding: utf-8
class Teacher::StructuresController < Teacher::ApplicationController

  # ajax
  def show
    structure = Structure.where(id: params[:id]).first
    tree = structure.structure_tree
    render_json({ tree: tree, root_folder_id: structure.id.to_s })
  end
end
