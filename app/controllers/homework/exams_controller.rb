# encoding: utf-8
class Homework::ExamsController < Homework::ApplicationController
  def new
    @klass = Klass.find(params[:klass_id])
    @title = @klass.name
  end

  def scan
    @exam = Exam.find(params[:id])
    k = @exam.klass
    @student_id_str = k.students.map { |e| e.id.to_s } .join(',')
    @student_name_str = k.students.map { |e| e.name.to_s } .join(',')
  end

  def create
    exam = Exam.create(title: params[:title], type: params[:type], subject: @current_user.subject)
    exam.teacher = @current_user
    k = Klass.where(id: params[:klass_id]).first
    exam.klass = k
    exam.save
    render json: {success: true, exam_id: exam.id.to_s} and return
  end

  def update
    exam = Exam.find(params[:id])
    (params[:student_id_ary] || []).each_with_index do |sid, index|
      s = User.where(id: sid).first
      next if s.blank?
      s = exam.scores.where(student_id: sid).first
      if s.present?
        s.update_score(params[:score_ary][index].to_i)
      else
        exam.scores.create(student_id: sid, type: exam.type, score: params[:score_ary][index].to_i)
      end
    end
    render json: {success: true} and return
  end

  def show
    @exam = Exam.where(id: params[:id]).first
    @title = @exam.klass.name

    @submit_number = @exam.scores.count
    @total_number = @exam.klass.students.length
    @lack_number = @total_number - @submit_number
    @submit_rate = @total_number == 0 ? "0" : ((@submit_number * 1.0 / @total_number) * 100).round.to_s + "%"
  end
end
