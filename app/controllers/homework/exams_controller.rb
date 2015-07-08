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
    render json: { success: true } and return
  end

  def entry
  end
end
