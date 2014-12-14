# encoding: utf-8
class Teacher::StudentsController < Teacher::ApplicationController

  before_filter :ensure_student, only: [:move, :copy, :destroy]

  def ensure_student
    begin
      @klass = current_user.classes.find(params[:class_id])
      @student = @klass.students.find(params[:id])
    rescue
      render_json ErrCode.ret_false(ErrCode::STUDENT_NOT_EXIST)
    end
  end

  def index
    current_user.ensure_default_class
    @classes = @current_user.classes.asc(:default)
    @cid = params[:cid]
    @keyword = params[:keyword].to_s.strip
  end

  def list
    current_user.ensure_default_class
    @klass = current_user.classes.where(id: params[:cid]).first
    k = params[:keyword]
    @students = [ ]
    if @klass.present?
      @klass.students.each do |s|
        @students << {
          id: s.id.to_s,
          name: s.name.to_s,
          email: s.email,
          mobile: s.mobile,
          class_id: @klass.id.to_s,
          class_name: @klass.name.to_s
        }
      end
      students_summary = { class_name: @klass.name }
    elsif k.present?
      current_user.classes.each do |c|
        c.students.each do |s|
          @students << {
            id: s.id.to_s,
            name: s.name.to_s,
            email: s.email,
            mobile: s.mobile,
            class_id: c.id.to_s,
            class_name: c.name.to_s
          } if s.name.include?(k) || s.email.include?(k) || s.mobile.include?(k)
        end
      end
      students_summary = { class_name: "搜索结果" }
    else
      current_user.classes.each do |c|
        c.students.each do |s|
          @students << {
            id: s.id.to_s,
            name: s.name.to_s,
            email: s.email,
            mobile: s.mobile,
            class_id: c.id.to_s,
            class_name: c.name.to_s
          }
        end
      end
      students_summary = { class_name: "所有学生" }
    end
    students_summary[:students_number] = @students.length
    students_table = {
      students_number: @students.length,
      students: @students
    }
    render_json({students_summary: students_summary, students_table: students_table})
  end

  def move
    @student.move_to(@klass, params[:new_class_id])
    render_json
  end

  def copy
    @student.copy_to(params[:new_class_id])
    render_json
  end

  def destroy
    @student.delete_from_class(@klass)
    render_json
  end
end
