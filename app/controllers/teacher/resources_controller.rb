# encoding: utf-8
class Teacher::ResourcesController < Teacher::ApplicationController

  def index
    @structures = Resource.where(type: "structure")
  end

  def show
    @resource = Resource.find(params[:id])
  end
end
