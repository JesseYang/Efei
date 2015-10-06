# encoding: utf-8
class Client::StudentsController < Client::ApplicationController
  skip_before_filter :client_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/client/students") and return
  end

  def index
    @return_path = main_page_client_users_path
    @title = "学生列表"
    @students = @current_user.client_students
  end

  def list
    @students = @current_user.client_students
    render json: {success: true, data: @students.map { |e| e.name }} and return
  end

  def new
    @return_path = client_students_path
    @title = "创建学生"
  end

  def create
    s = User.create_student(params[:student].merge({"client_id" => @current_user.id.to_s}))
    case s
    when ErrCode::BLANK_EMAIL_MOBILE
      flash[:notice] = "请填写邮箱或手机号"
    when ErrCode::EMAIL_EXIST
      flash[:notice] = "邮箱已存在"
    when ErrCode::MOBILE_EXIST
      flash[:notice] = "手机号已存在"
    else
      flash[:notice] = "创建成功"
    end
    redirect_to client_students_path and return
  end

  def update
    @student = User.find(params[:id])
    retval = @student.update_student(params[:student])
    if retval == true
      flash[:notice] = "更新成功"
    end
    redirect_to client_student_path(@student) and return
  end

  def show
    @return_path = client_students_path
    @student = User.find(params[:id])
    @title = "学生：" + @student.name

    image_url = "public/pdf/#{@student.id.to_s}.png"
    if !File.exist?(image_url)
      qr = RQRCode::QRCode.new(@student.id.to_s, :size => 4, :level => :h )
      png = qr.to_img
      png.resize(150, 150).save(image_url)
    end
    @image_url = "/pdf/#{@student.id.to_s}.png"
  end

  def coaches
    @return_path = client_students_path
    @student = User.find(params[:id])
    @coaches = @student.coaches
    @title = "学生：" + @student.name + "的老师"
  end

  def new_coach
    @student = User.find(params[:id])
    @coach = @current_user.client_coaches.where(name: params[:new_coach]).first
    if @coach.blank?
      flash[:notice] = "教师不存在"
    else
      @student.coaches << @coach
      flash[:notice] = "添加成功"
    end
    redirect_to action: :coaches and return
  end

  def delete_coach
    @student = User.find(params[:id])
    @coach = @current_user.client_coaches.where(id: params[:coach_id]).first
    if @coach.present?
      @student.coaches.delete(@coach)
      flash[:notice] = "删除成功"
    end
    redirect_to action: :coaches and return
  end

  def courses
    @return_path = client_students_path
    @student = User.find(params[:id])
    @courses = @student.student_courses
    @title = "学生：" + @student.name + "的课程"
  end

  def new_course
    @student = User.find(params[:id])
    @course = Course.where(name: params[:new_course]).first
    @student.student_courses << @course
    flash[:notice] = "添加成功"
    redirect_to action: :courses and return
  end

  def delete_course
    @student = User.find(params[:id])
    @course = Course.find(params[:course_id])
    @student.student_courses.delete(@course)
    flash[:notice] = "删除成功"
    redirect_to action: :courses and return
  end

  def destroy
    @student = User.find(params[:id])
    @student.destroy
    redirect_to client_students_path and return
  end
end
