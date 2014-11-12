module SurveyComponents::Student
  extend ActiveSupport::Concern

  # for students
  field :note_update_time, type: Hash, default: {}
  has_many :notes
  has_and_belongs_to_many :klasses, class_name: "Klass", inverse_of: :students

  def list_my_teachers
    teachers_info = self.klasses.map { |e| e.teacher } .uniq.map { |t| t.teacher_info_for_student }
    { success: true, teachers: teachers_info }
  end

  def self.search_teachers(subject, name)
    teachers = User.where(teacher: true, subject: subject, name: /#{name}/)
    teachers_info = teachers.map { |t| t.teacher_info_for_student }
    { success: true, teachers: teachers_info }
  end

  def teacher_info_for_student(with_classes = false)
    info = {
      id: self.id.to_s,
      name: self.name.to_s,
      subject: self.subject,
      school: self.school.name,
      desc: self.teacher_desc,
      avatar: ""
    }
    return info if !with_classes
    info[:classes] = []
    self.classes.each do |c|
      next if !c.visible
      info[:classes] << {
        id: c.id.to_s,
        name: c.name,
        desc: c.desc
      }
    end
    info
  end

  def list_notes
    self.notes.map { |e| [e.id.to_s, e.updated_at.to_i] }
  end

  def add_note(qid, summary = "", tag = "", topics = "")
    note = self.notes.where(question_id: qid).first
    if note.present?
      note.update_note(summary, tag, topics)
    else
      note = Note.create_new(qid, summary, tag, topics)
      self.notes << note
    end
    self.set_note_update_time(note.subject)
    return note
  end

  def update_note(nid, summary, tag, topics)
    note = self.notes.find(nid)
    return if note.nil?
    note.update_note(summary, tag, topics)
    self.set_note_update_time(note.subject)
    return note
  end

  def rm_note(nid)
    note = self.notes.find(nid)
    note.destroy if note.present?
    self.set_note_update_time(note.subject)
  end

  def set_note_update_time(subject)
    self.note_update_time[subject] = Time.now.to_i
    self.save
  end

  def export_note(note_id_str, has_answer, has_note, email)
    notes = []
    note_id_str.split(',').each do |note_id|
      n = Note.where(id: note_id).first
      next if n.blank?
      note = {
        "type" => n.type,
        "content" => n.content,
        "items" => n.items,
        "figures" => n.q_figures
      }
      if has_answer.to_s == "true"
        note.merge!({ "answer" => n.answer || -1, "answer_content" => n.answer_content })
      end
      if has_note.to_s == "true"
        note.merge!({ "tag" => n.tag, "topics" => n.topics.map { |e| e.name }, "summary" => n.summary })
      end
      notes << note
    end
    response = User.post("/ExportNote.aspx",
      :body => {notes: notes.to_json} )
    filepath = response.body
    download_path = "public/documents/导出-#{SecureRandom.uuid}.docx"

    open(download_path, 'wb') do |file|
      file << open("#{Rails.application.config.word_host}/#{URI.encode filepath}").read
    end
    ExportNoteEmailWorker.perform_async(email, download_path) if email.present?
    URI.encode(download_path[download_path.index('/')+1..-1])
  end
end