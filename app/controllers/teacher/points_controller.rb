#encoding: utf-8
class Teacher::PointsController < Teacher::ApplicationController

  # ajax
  def show
    point = Point.where(id: params[:id]).first
    tree = point.point_tree
    render_json({tree: tree, root_folder_id: point.id.to_s}) and return
  end
end
