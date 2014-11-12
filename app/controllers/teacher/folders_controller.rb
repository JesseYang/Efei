#encoding: utf-8
class Teacher::FoldersController < Teacher::ApplicationController

  # ajax
  def rename
    params[:id]
    params[:name]
  end

  # ajax
  def create
    params[:parent_id]
  end

  # ajax
  def destroy
  end

  # ajax
  def move
    params[:folder_id]
    params[:des_folder_id]
  end
end
