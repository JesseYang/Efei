# encoding: utf-8
class Teacher::SharesController < Teacher::ApplicationController
  layout :resolve_layout
  before_filter :ensure_homework, only: [:show, :stat, :settings, :generate]

  def ensure_homework
    begin
      @share = Share.find(params[:id])
      @editable = @share.editable
      @homework = @share.node
    rescue
      respond_to do |format|
        format.html
        format.json do
          render_json ErrCode.ret_false(ErrCode::HOMEWORK_NOT_EXIST) and return
        end
      end
    end
  end

  def show
    @title = @homework.name + "-编辑"
    render "teacher/homeworks/show"
  end

  def stat
    @title = @homework.name + "-统计"
    @notes = @share.notes
    @users = @notes.map { |e| e.user } .uniq

    @students = @users.select { |e| @current_user.has_student?(e) }
    @students_notes = @notes.select { |e| @students.include?(e.user) }

    @classes = @current_user.classes.map do |e|
      [e.name.to_s, e.id.to_s]
    end
    @classes.insert(0, ["全体学生", "-1"])
    render "teacher/homeworks/stat"
  end

  def settings
    @title = @homework.name + "-设置"
    @type = %w{basic export tag} .include?(params[:type]) ? params[:type] : "basic"
    case @type
    when "basic"
      @answer_time_type = @homework.answer_time_type || "no"
      @answer_time = @homework.format_answer_time
    when "export"
    when "tag"
      @tag_sets = current_user.tag_sets
      tag_set_ary = @homework.tag_set.split(',')
      all_tag_sets = current_user.tag_sets + TagSet.where(default: true)
      @tag_set_id = ""
      all_tag_sets.each do |tag_set|
        if tag_set_ary.uniq.sort == tag_set.tags.uniq.sort
          @tag_set_id = tag_set.id.to_s
        end
      end
    end
    render "teacher/homeworks/settings"
  end

  def generate
    file_name = @homework.generate(params[:question_qr_code].to_s == 'true', params[:app_qr_code].to_s == "true", params[:with_number].to_s == "true", params[:with_answer].to_s == "true", @share.id.to_s)
    download_url = "#{Rails.application.config.word_host}/#{file_name}"
    render_json({ download_url: download_url })
  end

  def resolve_layout
    case action_name
    when "show", "stat", "settings"
      "layouts/homework"
    else
      "layouts/teacher"
    end
  end
end
