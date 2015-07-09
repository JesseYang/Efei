# encoding: utf-8
class Homework::ExamsController < Homework::ApplicationController
  def new
    @klass = Klass.find(params[:klass_id])
    @title = @klass.name
  end

  def create
    exam = Exam.create(type: params[:type], subject: @current_user.subject)
    exam.teacher = @current_user
    k = Klass.where(id: params[:klass_id]).first
    exam.klass = k
    exam.save
    student_id_ary = k.students.map { |e| e.id.to_s }
    student_name_ary = k.students.map { |e| e.name.to_s }
    retval = {
      exam_id: exam.id.to_s,
      student_id_ary: student_id_ary,
      student_name_ary: student_name_ary
    }
    render json: retval.merge({success: true}) and return
  end

  def update
    render json: {success: true} and return
  end
end
