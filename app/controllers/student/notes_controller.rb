# encoding: utf-8
class Student::NotesController < Student::ApplicationController
  before_filter :require_student

  def create
    begin
      note = current_user.add_note(params[:question_id], params[:homework_id], params[:summary].to_s, params[:tag].to_s, params[:topics].to_s)
      new_teacher = note.check_teacher(current_user)
      note.set_answer
      retval = { note: note, note_update_time: current_user.note_update_time }
      retval[:teacher] = new_teacher.teacher_info_for_student(true) if new_teacher.present?
      render_with_auth_key retval
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      render_with_auth_key ErrCode.ret_false(ErrCode::QUESTION_NOT_EXIST)
    end
  end

  def batch
    begin
      notes = (params[:question_ids] || []).each_with_index.map { |qid, i| current_user.add_note_without_update(qid, (params[:homework_ids] || [])[i]) }
      new_teachers = notes.map { |n| n.check_teacher(current_user) }
      new_teachers = new_teachers.select { |e| !e.nil? } .uniq
      retval = { note_ids: notes.map { |e| e.id.to_s }, note_update_time: current_user.note_update_time }
      if new_teachers.present?
        retval[:teachers] = new_teachers.map { |e| e.teacher_info_for_student(true) }
      end
      render_with_auth_key retval
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      render_with_auth_key ErrCode.ret_false(ErrCode::QUESTION_NOT_EXIST)
    end
  end

  def note_update_time
    render_with_auth_key({ note_update_time: current_user.note_update_time })
  end

  def index
    @subject = params[:subject].to_i
    @time_period = params[:time_period].to_i
    @keyword = params[:keyword]
    @search_notes = current_user.notes.desc(:created_at)
    @search_notes = @search_notes.where(subject: @subject) if @subject != 0
    @search_notes = @search_notes.where(:created_at.gt => Time.now.to_i - @time_period) if @time_period != 0
    if @keyword != ""
      @search_notes = @search_notes.any_of({summary: /#{@keyword}/}, {topic_str: /#{@keyword}/}, {tag: /#{@keyword}/})
    end
    @condition = @subject != 0 || @time_period != 0 || @keyword != ""
    @notes = auto_paginate @search_notes
    respond_to do |format|
      format.html do
      end
      format.json do
        render_with_auth_key({ notes: current_user.list_notes }) and return
      end
    end
  end

  def list
    notes = []
    params[:note_ids].split(',').each do |nid|
      note = current_user.notes.where(id: nid).first
      next if note.blank?
      note["last_update_time"] = note.updated_at.to_i
      notes << note
    end
    render_with_auth_key({notes: notes}) and return
  end

  def show
    begin
      note = current_user.notes.find(params[:id])
      note["last_update_time"] = note.updated_at.to_i
      note["create_time"] = note.created_at.to_i
      note.set_answer
      render_with_auth_key({ note: note })
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      render_with_auth_key ErrCode.ret_false(ErrCode::NOTE_NOT_EXIST)
    end
  end

  def update
    begin
      note = current_user.update_note(params[:id], params[:summary], params[:tag].to_s, params[:topics].to_s)
      note.set_answer
      render_with_auth_key({ note: note, note_update_time: current_user.note_update_time })
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      render_with_auth_key ErrCode.ret_false(ErrCode::NOTE_NOT_EXIST)
    end
  end

  def destroy
    begin
      current_user.rm_note(params[:id])
      respond_to do |format|
        format.json do
          render_with_auth_key({ note_update_time: current_user.note_update_time })
        end
        format.html do
          redirect_to action: :index and return
        end
      end
    rescue Mongoid::Errors::InvalidFind, Mongoid::Errors::DocumentNotFound
      respond_to do |format|
        format.json do
          render_with_auth_key ErrCode.ret_false(ErrCode::NOTE_NOT_EXIST)
        end
        format.html do
          redirect_to action: :index and return
        end
      end
    end
  end

  def export
    file_path = current_user.export_note(
      params[:note_id_str],
      params[:has_answer].to_s == "true" || params[:has_answer].to_s == "1",
      params[:has_note].to_s == "true" || params[:has_note].to_s == "1",
      params[:email]
    )
    render_with_auth_key({ file_path: file_path })
  end

  def update_tag
    n = current_user.notes.find(params[:id])
    tag = n.tag_set.split(',')[params[:tag_index].to_i]
    n.update_attribute(:tag, tag)
    render_json({ tag: tag }) and return
  end

  def update_topic_str
    n = current_user.notes.find(params[:id])
    n.update_attribute(:topic_str, params[:topic_str])
    render_json and return
  end

  def update_summary
    n = current_user.notes.find(params[:id])
    n.update_attribute(:summary, params[:summary])
    render_json({summary: params[:summary], paras: params[:summary].split("\n")}) and return
  end

  def web_export
    if params[:note_id].present?
      note_id_str = params[:note_id]
    else
      subject = params[:subject].to_i
      time_period = params[:time_period].to_i
      keyword = params[:keyword]
      search_notes = current_user.notes.desc(:created_at)
      search_notes = search_notes.where(subject: subject) if subject != 0
      search_notes = search_notes.where(:created_at.gt => Time.now.to_i - time_period) if time_period != 0
      if keyword != ""
        search_notes = search_notes.any_of({summary: /#{keyword}/}, {topic_str: /#{keyword}/}, {tag: /#{keyword}/})
      end
      note_id_str = search_notes.map { |e| e.id.to_s } .join(',')
    end
    file_path = current_user.export_note(
      note_id_str,
      params[:has_answer].to_s == "true",
      params[:has_note].to_s == "true",
      ""
    )
    render_json({file_path: file_path}) and return
  end
end
