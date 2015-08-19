class WelcomeController < ApplicationController
  layout :resolve_layout
  def index
    if params[:echostr].present?
      render text: params[:echostr] and return
    end
  end

  def weixin
    case params[:xml]["MsgType"]
    when "text"
      if params[:xml]["Content"] == "我是老师"
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "text",
          "Content" => "<a href='#{Weixin.generate_authorize_link(Rails.application.config.server_host + "/coach/students")}/'>我的学生</a>"
        }
        render :xml => data.to_xml(root: "xml") and return
      elsif params[:xml]["Content"] == "我的作业平台"
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "text",
          "Content" => "<a href='#{Platform.generate_authorize_link(Rails.application.config.server_host + "/homework/klasses")}/'>我的作业平台</a>"
        }
        render :xml => data.to_xml(root: "xml") and return
      else
        render text: "" and return
      end
    when "event"
      if params[:xml]["Event"] == "CLICK" && ["MSWK", "ZCKD", "JYZT"].include?(params[:xml]["EventKey"])
        news = WeixinNews.where(active: true, type: params[:xml]["EventKey"]).desc(:created_at).limit(3)
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "news",
          "ArticleCount" => news.length,
          "Articles" => [ ]
        }
        news.each_with_index do |n, i|
          data["Articles"] << {
            "item_#{i}" => {
              "Title" => n.title,
              "Description" => n.desc,
              "PicUrl" => Rails.application.config.server_host + n.pic_url,
              "Url" => n.url
            }
          }
        end
        retval = data.to_xml(root: "xml").gsub(/item-\d/, "item").gsub("<Article>", "").gsub("</Article>", "")
        render :xml => retval and return
      end
=begin
      if params[:xml]["Event"] == "subscribe"
        data = {
          "ToUserName" => params[:xml]["FromUserName"],
          "FromUserName" => params[:xml]["ToUserName"],
          "CreateTime" => Time.now.to_i,
          "MsgType" => "text",
          "Content" => "有福啦！易飞学堂邀请顶级名师团为吉林父老举办免费讲座！8月开讲，点击<a href='http://efei.org/lecture_users/new'>这里</a>报名！！！"
        }
        render :xml => data.to_xml(root: "xml") and return
      end
=end
    end
  end

  def redirect
    if current_user.present? && current_user.super_admin
      redirect_to "/admin/supers" and return
    elsif current_user.present? && current_user.admin && current_user.permission > 0
      redirect_to current_user.default_admin_path and return
    end
    flash[:notice] = params[:notice]
    if current_user.try(:teacher)
      redirect_to teacher_nodes_path and return
    elsif current_user.present?
      redirect_to student_notes_path and return
    else
      redirect_to new_account_session_path + "?role=#{params[:role]}"
    end
  end

  def student_app
    
  end

  def app_download
    
  end

  def student_android_app_download
    send_file "public/Efei.apk", type: "application/vnd.android.package-archive"
  end

  def student_ios_app_download

  end

  def app_version
    retval = { success: true, android: "1.0", ios: "1.0", android_url: "", ios_url: "" }
    retval[:auth_key] = current_user.generate_auth_key if current_user.present?
    render json: retval and return
  end

  private

  def resolve_layout
    'layouts/welcome'
=begin
    case action_name
    when "index"
      'layouts/index'
    when "student_app", "app_download"
      'layouts/welcome'
    end
=end
  end
end
