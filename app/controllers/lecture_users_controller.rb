# encoding: utf-8
class LectureUsersController < ApplicationController

  def new
  end

  def create
  	u = LectureUser.create(mobile: params[:mobile])
  	@mobile = params[:mobile]
  end
end
