# encoding: utf-8
class LectureUsersController < ApplicationController

  def index
    @users = LectureUser.all.desc(:created_at).uniq { |e| e.mobile }
  end

  def new
  end

  def create
    u = LectureUser.create(mobile: params[:mobile])
    @mobile = params[:mobile]
  end
end
