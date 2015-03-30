# encoding: utf-8
class SchoolsController < ApplicationController

  def index
    school_names = []
    School.where(nickname: /#{params[:term]}/).each do |e|
      school_names << e.name
    end
    render json: school_names and return
  end
end
