class WelcomeController < ApplicationController
  layout :resolve_layout
  def index
    if params[:echostr].present?
      render text: params[:echostr] and return
    end
  end

  def weixin
    if params[:xml]["Content"] == "我是老师"
      data = {
        "ToUserName" => params["xml"]["FromUserName"],
        "FromUserName" => params["xml"]["ToUserName"],
        "CreateTime" => Time.now.to_i,
        "MsgType" => "text",
        "Content" => "<a href='http://www.baidu.com'>CLICK HERE</a>"
      }
      render :xml => data.to_xml(root: "xml") and return
    else
      render text: "" and return
    end
  end

  def redirect
    flash[:notice] = params[:notice]
    # if current_user.try(:school_admin)
    #   redirect_to school_admin_teachers_path and return
    # elsif current_user.try(:teacher)
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
