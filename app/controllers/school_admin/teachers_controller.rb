#encoding: utf-8
require 'csv'
require "string/utf8"
class SchoolAdmin::TeachersController < SchoolAdmin::ApplicationController

  def index
    @batch = params[:batch]
    @school = current_user.school
    # @teachers = @school.teachers.where(school_admin: false)
    @teachers = @school.teachers
    if params[:subject].to_i != 0
      @teachers = @teachers.where(subject: params[:subject].to_i)
    end
    if params[:keyword].present?
      @teachers = @teachers.where(name: /#{params[:keyword]}/)
    end
    if params[:sort].present?
      @teachers = params[:dir] == "true" ? @teachers.desc(params[:sort].to_sym) : @teachers.asc(params[:sort].to_sym)
    else
      params[:sort] = "name"
      params[:dir] = "true"
      @teachers = @teachers.desc(:name)
    end
    @teachers = auto_paginate @teachers
  end

  def create
    @teacher = User.new(subject: params[:teacher]["subject"],
      name: params[:teacher]["name"],
      email: params[:teacher]["email"],
      password: params[:teacher]["password"],
      teacher: true)
    @teacher.school = current_user.school
    @teacher.save(validate: false)
    redirect_to action: :index and return
  end

  def csv_header
    csv = CSV.generate do |rows|
      rows << ["学科", "姓名", "邮箱", "密码"]
    end
    send_data(csv.encode("gb2312"), :filename => "批量创建-#{current_user.school.name}.csv", :type => 'text/csv')
  end

  def batch_create
    unless(File.exist?("public/uploads"))
      Dir.mkdir("public/uploads")
    end
    unless(File.exist?("public/uploads/csv"))
      Dir.mkdir("public/uploads/csv")
    end
    csv_origin = params[:file]
    filename = Time.now.strftime("%s")+'_'+(csv_origin.original_filename)
    File.open("public/uploads/csv/#{filename}", "wb") do |f|
      f.write(csv_origin.read)
    end
    csv = File.read("public/uploads/csv/#{filename}").utf8!
    result = User.batch_create_teacher(current_user, csv)

    send_data(result.encode("gb2312"),
      :filename => "批量创建处理结果-#{Time.now.strftime("%M-%d_%T")}.csv",
      :type => "text/csv")
  end

  def destroy
    @teacher = User.find(params[:id])
    if @teacher.school_admin
      flash[:notice] = "无法删除学校管理员"
    else
      @teacher.destroy
      flash[:notice] = "成功删除教师"
    end
    redirect_to action: :index and return
  end

  def show
    @teacher = User.find(params[:id])
  end

  def update
    @teacher = User.find(params[:id])
    if params["email"] != @teacher.email && User.where(email: params["email"]).present?
      error_msg = "指定邮箱已经存在"
      success = false
    else
      @teacher.update_attributes(email: params["email"],
        subject: params["subject"],
        name: params["name"])
      if params[:password].present?
        @teacher.password = params[:password]
        @teacher.save(validate: false)
      end
      success = true
    end
    render json: { success: success, error_msg: error_msg } and return
  end

  def update_password
    @teacher = User.find(params[:id])
    @teacher.update_attributes(subject: params[:teacher]["subject"],
      name: params[:teacher]["name"])
    flash[:notice] = "成功更新教师密码"
    redirect_to action: :show, id: @teacher.id and return
  end
end
