#encoding: utf-8
require 'csv'
class SchoolAdmin::TeachersController < SchoolAdmin::ApplicationController

  def index
    @school = current_user.school
    @teachers = @school.teachers.where(school_admin: false)
    if params[:subject].present?
      @teachers = @teachers.where(subject: params[:subject].to_i)
    end
    if params[:search].present?
      @teachers = @teachers.where(name: /#{params[:search]}/)
    end
    @subjects = Subject::NAME.map do |key, value|
      {id: key, name: value}
    end
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
    send_data(["学科", "姓名", "邮箱"].to_csv, :filename => "批量创建-#{current_user.school.name}.csv", :type => 'text/csv')
  end

  def batch_create
    unless(File.exist?("public/uploads"))
      Dir.mkdir("public/uploads")
    end
    unless(File.exist?("public/uploads/csv"))
      Dir.mkdir("public/uploads/csv")
    end
    csv_origin = params["import_file"]
    filename = Time.now.strftime("%s")+'_'+(csv_origin.original_filename)
    File.open("public/uploads/csv/#{filename}", "wb") do |f|
      f.write(csv_origin.read)
    end
    csv = File.read("public/uploads/csv/#{filename}").utf8!
    result = User.batch_create_teacher(current_user, csv)
    if result[:error_msg].present?
      csv_file = CSV.open("public/uploads/csv/error_#{filename}", "wb") do |csv|
        result.each {|a| csv << a}
      end
      result[:error] = "uploads/csv/error_#{filename}"
    end
    render_json_auto result and return
  end

  def destroy
    @teacher = User.find(params[:id])
    @teacher.destroy
    redirect_to action: :index
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
