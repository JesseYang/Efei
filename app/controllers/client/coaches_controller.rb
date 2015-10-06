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
    @return_path = client_coaches_path
    @title = "创建教师"
  end

  def create
    c = User.create_coach(params[:coach].merge({"client_id" => @current_user.id.to_s}))
    case c
    when ErrCode::BLANK_EMAIL_MOBILE
      flash[:notice] = "请填写邮箱或手机号"
    when ErrCode::COACH_NUMBER_EXIST
      flash[:notice] = "教师工号已经存在"
    when ErrCode::EMAIL_EXIST
      flash[:notice] = "邮箱已存在"
    when ErrCode::MOBILE_EXIST
      flash[:notice] = "手机号已存在"
    else
      flash[:notice] = "创建成功"
    end
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

    image_url = "public/pdf/#{@coach.id.to_s}.png"
    if !File.exist?(image_url)
      qr = RQRCode::QRCode.new(@coach.id.to_s, :size => 4, :level => :h )
      png = qr.to_img
      png.resize(150, 150).save(image_url)
    end
    @image_url = "/pdf/#{@coach.id.to_s}.png"
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
    if @sutdent.blank?
      flash[:notice] = "学生不存在"
    else
      @coach.students << @student
      flash[:notice] = "添加成功"
    end
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

  def destroy
    @coach = User.find(params[:id])
    @coach.destroy
    redirect_to client_coaches_path and return
  end
end
