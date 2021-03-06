# encoding: utf-8
class Teacher::SettingsController < Teacher::ApplicationController

  def show
    @title = "个人设置"
    @type = params[:type].present? ? params[:type] : "update"
  end

  def update
    current_user.update_attributes({name: params[:teacher]["name"], subject: params[:teacher]["subject"].to_i})
    if params[:teacher]["school"].present?
      s = School.where(name: params[:teacher]["school"]).first || School.create(name: params[:teacher]["school"])
      current_user.update_attribute(:school_id, s.id.to_s)
    end
    flash[:notice] = "更新成功"
    redirect_to action: :show, type: "update" and return
  end

  def update_password
    if current_user.valid_password?(params[:password])
      if params[:new_password] != params[:new_password_confirmation]
        flash[:notice] = "新密码与确认不一致"
        redirect_to action: :show, type: "update_password" and return
      else
        current_user.password = params[:new_password]
        current_user.save
        sign_in(User.find(current_user.id), bypass: true)
        flash[:notice] = "更新成功"
        redirect_to action: :show, type: "update_password" and return
      end
    else
      flash[:notice] = "当前密码不正确"
      redirect_to action: :show, type: "update_password" and return
    end
  end

  def colleague_info
    retval = [ ] if current_user.school.blank?
    retval = current_user.school.teachers.any_of( {name: /#{params[:term]}/}, {email: /#{params[:term]}/} ).select do |e|
      e.id.to_s != current_user.id.to_s
    end .map do |e|
      "#{e.name}(#{e.email})"
    end
    retval = [ "没有搜索到同事" ] if retval.blank?
    render json: retval and return
  end

  def teacher_info
    info = params[:info]
    list = params[:list].split(',')
    ret = info.scan(/[（\(](.*)[\)）]/)
    if ret.blank?
      render_json and return
    else
      u = User.where(email: ret[0][0]).first
      render_json and return if u.blank? || list.include?(u.id.to_s)
      render_json({id: u.id.to_s, name: u.name.to_s}) and return
    end
  end
end
