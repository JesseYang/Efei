class Teacher::ApplicationController < ApplicationController
  layout 'layouts/teacher'

  before_filter :require_teacher, :init_teacher

  def init_teacher
    @compose = current_user.ensure_compose
    @compose_qid_str = ( @compose.questions || [] ).map { |e| e.id.to_s }.join(',')
    @show_compose = @compose.homework.present?
    @compose_homework_name = @show_compose ? @compose.homework.name.to_s : ""
    @included_qid_str = @show_compose ? @compose.homework.q_ids.join(',') : ""
  end
end
