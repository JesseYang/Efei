# encoding: utf-8
class Student::SettingsController < Student::ApplicationController

  def show
    @type = params[:type].present? ? params[:type] : "update"
  end

  def update
    current_user.update_attributes({name: params[:student]["name"]})
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
end
