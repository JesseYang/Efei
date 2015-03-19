# encoding: utf-8
class Student::TeachersController < Student::ApplicationController

  before_filter :require_student

  def index
    if params[:scope].to_i == 1
      retval = current_user.list_my_teachers
      render_with_auth_key retval
    else
      retval = User.search_teachers(params[:subject].to_i, params[:name] || "")
      render_with_auth_key retval
    end
  end


  def create
    begin
      t = User.find(params[:teacher_id])
      retval = t.add_to_class(params[:class_id], current_user)
      render_with_auth_key retval
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      render_with_auth_key ErrCode.ret_false(ErrCode::TEACHER_NOT_EXIST)
    end
  end

  def destroy
    begin
      t = User.find(params[:id])
      t.remove_student(current_user)
      render_with_auth_key
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      render_with_auth_key ErrCode.ret_false(ErrCode::TEACHER_NOT_EXIST)
    end
  end


  # for web page operations
  def list
    @teachers = current_user.klasses.map { |e| e.teacher } .uniq
    if params[:scope].to_i == 1
      return
    else
      @new_teachers = User.where(teacher: true, name: /#{params[:keyword]}/)
      teachers_data = @new_teachers.map do |t|
        {
          id: t.id.to_s,
          name: t.name,
          school_name: t.school.try(:name).to_s,
          subject: Subject::NAME[t.subject],
          has: @teachers.include?(t).to_s
        }
      end
      render_json({teachers: teachers_data}) and return
    end
  end

  def list_classes
    t = User.find(params[:id])
    classes = []
    t.classes.each do |c|
      next if !c.visible
      classes << {
        id: c.id.to_s,
        name: c.name,
        desc: c.desc,
        teacher_id: t.id.to_s
      }
    end
    render_json({classes: classes}) and return
  end

  def add_teacher
    t = User.find(params[:id])
    retval = t.add_to_class(params[:class_id], current_user)

    respond_to do |format|
      format.html do
        flash[:notice] = "添加教师成功"
        redirect_to "/student/teachers/list?scope=1" and return
      end
      format.json do
        render json: { success: true } and return
      end
    end

  end

  def remove_teacher
    t = User.find(params[:id])
    t.remove_student(current_user)
    flash[:notice] = "删除教师成功"
    redirect_to "/student/teachers/list?scope=1" and return
  end
end
