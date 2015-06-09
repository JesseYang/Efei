#encoding: utf-8
class Admin::CoachesController < Admin::ApplicationController

  def index
    @coaches = auto_paginate User.where(coach: true)
  end

  def create
    retval = User.create_coach(params[:coach])
    if retval != true
      flash[:notice] = ErrCode.message(retval)
    else
      flash[:notice] = "创建成功"
    end
    redirect_to action: :index and return
  end

  def update
    @coach = User.find(params[:id])
    retval = @coach.update_coach(params[:coach])
    if retval != true
      flash[:notice] = ErrCode.message(retval)
    else
      flash[:notice] = "更新成功"
    end
    redirect_to action: :index and return
  end

  def destroy
    @coach = User.find(params[:id])
    @coach.destroy
  end
end
