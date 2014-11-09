# encoding: utf-8
class Teacher::TagsController < Teacher::ApplicationController
  def create
    retval = current_user.create_tag(params[:tag])
  end

  def update
  end

  def destroy
  end
end
