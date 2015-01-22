class Teacher::ApplicationController < ApplicationController
  layout 'layouts/teacher'

  before_filter :require_teacher, :init_teacher

  def init_teacher
    @compose = current_user.compose
    @compose_qid_str = @compose.questions.map { |e| e.id.to_s }.join(',')
    @show_compose = @compose.homework.present?
  end
end
