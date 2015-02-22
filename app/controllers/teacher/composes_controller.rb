# encoding: utf-8
class Teacher::ComposesController < Teacher::ApplicationController

  before_filter :ensure_compose, only: [:add, :remove, :index, :destroy, :confirm]

  def ensure_compose
    if current_user.compose.blank? || current_user.compose.homework.blank?
      render_json ErrCode.ret_false(ErrCode::COMPOSE_NOT_EXIST) and return
    end
  end

  def index
    @questions = current_user.compose.questions
  end

  def create
    homework = Homework.find(params[:homework_id])
    compose = current_user.ensure_compose(homework.id)
    if compose.homework.present?
      render_json({ homework_name: compose.homework.name }) and return
    else
      compose.homework = homework
      compose.questions = nil
      compose.save
      render_json and return
    end
  end

  def add
    current_user.compose.add_question(params[:question_id])
    render_json({ question_number: User.find(current_user.id).compose.questions.length }) and return
  end

  def remove
    current_user.compose.remove_question(params[:question_id])
    render_json({ question_number: current_user.compose.questions.length }) and return
  end

  def clear
    c = current_user.compose
    c.questions = nil
    c.save
    render_json
  end

  def confirm
    compose = current_user.compose
    h = compose.homework
    compose.questions.each do |q|
      h.q_ids.push(q.id.to_s) if !h.q_ids.include?(q.id.to_s)
      h.questions << q
    end
    h.save
    compose.homework = nil
    compose.questions = nil
    compose.save
    render_json
  end

  def destroy
    c = current_user.compose
    c.homework = nil
    c.questions = nil
    c.save
    render_json
  end
end
