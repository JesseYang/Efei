# encoding: utf-8
class Teacher::TagSetsController < Teacher::ApplicationController
  def create
    retval = current_user.create_tag_set(params[:tag_set])
    render_json retval
  end

  def update
  	retval = current_user.update_tag_set(params[:id], params[:tag_set])
  	render_json retval
  end

  def destroy
  	retval = current_user.remove_tag_set(params[:id])
  	render_json retval
  end
end
