#encoding: utf-8
class Admin::GroupsController < Admin::ApplicationController

  def update_select
    group = Group.find(params[:id])
    group.update_attributes({
      random_select: params[:random_select],
      random_number: params[:random_number].to_i,
      manual_select: params[:manual_select] || []
    })
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
