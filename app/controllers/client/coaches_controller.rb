# encoding: utf-8
class Client::CoachesController < Client::ApplicationController
  skip_before_filter :client_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/client/coaches") and return
  end

  def index
    @return_path = main_page_client_users_path
    @title = "教师列表"
    @coaches = @current_user.client_coaches
  end

  def list
    @coaches = @current_user.client_coaches
    render json: {success: true, data: @coaches.map { |e| e.name }} and return
  end

  def new
    @title = "创建教师"
  end

  def create
    c = User.create_coach(params[:coach].merge({"client_id" => @current_user.id.to_s}))
    redirect_to client_coaches_path and return
  end

  def update
    @coach = User.find(params[:id])
    retval = @coach.update_coach(params[:coach])
    if retval == true
      flash[:notice] = "更新成功"
    end
    redirect_to client_coach_path(@coach) and return
  end

  def show
    @return_path = client_coaches_path
    @coach = User.find(params[:id])
    @title = "教师：" + @coach.name
  end

  def students
    @return_path = client_coaches_path
    @coach = User.find(params[:id])
    @students = @coach.students
    @title = "教师：" + @coach.name + "的学生"
  end

  def new_student
    @coach = User.find(params[:id])
    @student = @current_user.client_students.where(name: params[:new_student]).first
    @coach.students << @student
    flash[:notice] = "添加成功"
    redirect_to action: :students and return
  end

  def delete_student
    @coach = User.find(params[:id])
    @student = @current_user.client_students.where(id: params[:student_id]).first
    if @student.present?
      @coach.students.delete(@student)
      flash[:notice] = "删除成功"
    end
    redirect_to action: :students and return
  end
end
