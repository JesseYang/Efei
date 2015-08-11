#encoding: utf-8
class Admin::SupersController < Admin::ApplicationController
  before_filter :require_super_admin

  def require_super_admin
    if @current_user.super_admin != true
      render text: "没有权限" and return
    end
  end

  def index
    @admins = User.where(:super_admin.ne => true, admin: true).desc(:created_at)
  end

  def update
    u = User.where(id: params[:id]).first
    if u.admin == false
      render json: {success: false} and return
    else
      u.permission = params[:permission]
      u.save
      render json: {success: true} and return
    end
  end


  def create
    u = User.find_by_email_mobile(params[:email_mobile])
    if u.blank?
      flash[:notice] = "用户不存在"
    elsif u.admin
      flash[:notice] = "已经是管理员"
    else
      u.admin = true
      u.permission = 0
      u.save
      flash[:notice] = "添加成功"
    end
    redirect_to action: :index and return
  end

  def destroy
    u = User.where(id: params[:id]).first
    if u.present?
      u.admin = false
      u.save
    end
    flash[:notice] = "删除成功"
    redirect_to action: :index and return
  end
end
