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
    # ensure default class
    if !current_user.classes.where(default: true).first
      current_user.classes.create(default: true, name: "其他")
    end
    @classes = @current_user.classes.asc(:default)
    @klass = current_user.classes.where(id: params[:cid]).first
    if @klass.present?
      @cid = @klass.id.to_s
      @students = @klass.students
    else
      @cid = ""
      @students = current_user.classes.map { |c| c.students }.flatten
    end
  end

  def move
    @student.move_to(@klass, params[:new_class_id])
  end

  def copy
    @student.copy_to(params[:new_class_id])
  end

  def destroy
    
  end
end
