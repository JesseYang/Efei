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
    render json: { success: true, id: exam.id.to_s } and return
  end

  def entry
    # get the student list
    @exam = Exam.where(id: params[:id]).first
    @klass = @exam.klass
    @students = @klass.students
    @student_id_str = @students.map { |e| e.id.to_s } .join(',')
    @student_name_str = @students.map { |e| e.name } .join(',')
  end
end
