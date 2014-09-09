# encoding: utf-8
class Student::NotesController < Student::ApplicationController
  before_filter :require_sign_in

  def index
    params[:per_page] = 5
    start_time = params[:period].present? ? Time.now.to_i - params[:period].to_i : 0
    @notes = current_user.list_notes(params[:note_type].to_i, params[:subject].to_i, start_time, params[:keyword])
    @note_id_str = @notes.map { |e| e.id.to_s } .join(',')
    @subject = params[:subject].to_i
    @notes = auto_paginate @notes
  end

  def show
    @note = current_user.notes.find(params[:id])
  end

  def update
    @note = Note.where(id: params[:id]).first
    if current_user.note_ids.map { |e| e.to_s } .include?(params[:id])
      @note.update_note(params[:summary], params[:note_type], params[:topics])
    else
      @note = Note.create_new(@note.question_id.to_s, params[:summary], params[:note_type], params[:topics])
      current_user.notes << @note
    end
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true, note_id: @note.id.to_s }
      end
    end
  end

  def destroy
    note = current_user.notes.where(id: params[:id])
    note.destroy
    redirect_to action: :index
  end

  def export
    file_path = current_user.export_note(
      params[:note_id_str],
      params[:has_answer].to_s == "true",
      params[:has_note].to_s == "true",
      params[:send_email].to_s == "true",
      params[:email]
    )
    respond_to do |format|
      format.html
      format.json do
        render json: { file_path: file_path }
      end
    end
  end
end
