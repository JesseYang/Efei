#encoding: utf-8
class Admin::TeachersController < Admin::ApplicationController

  def index
    @teachers = auto_paginate User.where(tablet_teacher: true).desc(:created)
  end

  def create
    # save the avatar file
    avatar = Avatar.new
    avatar.avatar = params[:avatar]
    filetype = "png"
    avatar.store_avatar!
    filepath = avatar.avatar.file.file
    avatar_url = "/avatars/" + filepath.split("/")[-1]

    # create the new tablet teacher
    @teacher = User.new(name: params[:teacher]["name"],
      tablet_teacher: true,
      desc: params[:teacher]["desc"],
      avatar_url: avatar_url,
      teacher: true)
    @teacher.save(validate: false)
    redirect_to action: :index and return
  end

  def update
    @teacher = User.find(params[:id])
    @teacher.name = params[:teacher]["name"]
    @teacher.desc = params[:teacher]["desc"]

    if params[:avatar].present?
      # also update avatar
      avatar = Avatar.new
      avatar.avatar = params[:avatar]
      filetype = "png"
      avatar.store_avatar!
      filepath = avatar.avatar.file.file
      avatar_url = "/avatars/" + filepath.split("/")[-1]
      @teacher.avatar_url = avatar_url
    end
    @teacher.save
    redirect_to action: :index and return
  end

  def destroy
    t = User.find(params[:id])
    if t.tablet_teacher && t.courses.blank?
      t.destroy
      # remove the avatar file
      File.delete("public" + t.avatar_url)
    end
    redirect_to action: :index and return
  end
end
