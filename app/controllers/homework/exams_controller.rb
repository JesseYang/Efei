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
    student_id_str = k.students.map { |e| e.id.to_s } .join(',')
    student_name_str = k.students.map { |e| e.name.to_s } .join(',')
    retval = {
      exam_id: exam.id.to_s,
      student_id_str: student_id_str,
      student_name_str: student_name_str
    }
    render json: retval.merge({success: true}) and return
  end
end
