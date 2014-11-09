# encoding: utf-8
class Teacher::TagSetsController < Teacher::ApplicationController
  def create
    retval = current_user.create_tag_set(params[:tag_set_str])
  end

  def update
  	retval = current_user.update_tag_set(params[:id].to_i, params[:tag_set_str])
  end

  def destroy
  	retval = current_user.remove_tag_set(params[:id.to_i], params[:tag_set_str])
  end
end
