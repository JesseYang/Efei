# encoding: utf-8
require 'prawn'
require "prawn/measurement_extensions"
module UserComponents::Student
  extend ActiveSupport::Concern

  included do
    field :note_update_time, type: Hash, default: {}

    # for tablet users
    field :tablet, type: Boolean, default: false
    field :city, type: String, default: ""
    field :school_name, type: String, default: ""
    field :grade, type: String, default: ""
    # 0 for senior school, 1 for junior school, 2 for primary school
    field :phase, type: Integer, default: -1
    field :entrance_year, type: String, default: "-1"
    field :student_number, type: String, default: ""
    field :parent_name, type: String, default: ""
    field :parent_mobile, type: String, default: ""
    has_many :notes
    has_and_belongs_to_many :student_local_courses, class_name: "LocalCourse", inverse_of: :students
    has_many :student_answers, class_name: "Answer", inverse_of: :student
    has_many :student_study_reports, class_name: "StudyReport", inverse_of: :student
    has_many :studies, class_name: "Study", inverse_of: :student
    has_and_belongs_to_many :klasses, class_name: "Klass", inverse_of: :students
    has_many :scores, class_name: "Score", inverse_of: :student

    has_many :learn_logs, class_name: "LearnLog", inverse_of: :student
    has_many :action_logs, class_name: "LearnLog", inverse_of: :student

    has_many :student_weixin_binds, class_name: "WeixinBind", inverse_of: :student
  end

  module ClassMethods
    def search_teachers(subject, name)
      if name.blank?
        return { success: true, teachers: [] }
      end
      if subject == 0
        teachers = User.where(teacher: true, name: /#{name}/)
      else
        teachers = User.where(teacher: true, subject: subject, name: /#{name}/)
      end
      teachers_info = teachers.map { |t| t.teacher_info_for_student(true) }
      { success: true, teachers: teachers_info }
    end

    def create_student(student)
      new_student = User.create({
        tablet: true,
        name: student["name"],
        email: student["email"],
        mobile: student["mobile"],
        city: student["city"],
        school_name: student["school_name"],
        phase: student["phase"],
        entrance_year: student["entrance_year"],
        student_number: student["student_number"],
        parent_name: student["parent_name"],
        parent_mobile: student["parent_mobile"]
      })
      new_student
    end

    def phase_for_select
      hash = { "请选择" => -1 }
      hash["高中"] = 0
      hash["初中"] = 1
      hash
    end

    def entrance_year_for_select
      hash = { "请选择" => -1, "2013" => "2013", "2014" => "2014", "2015" => "2015" }
      hash
    end

    def phase_text(phase)
      h = { "-1" => "未知", "1" => "初中", "0" => "高中" }
      h[phase.to_s]
    end

    def entrance_year_text(entrance_year)
      return "未知" if entrance_year == "-1"
      return entrance_year
    end
  end

  def download_cover(local_course)
    qr = RQRCode::QRCode.new(self.id.to_s, :size => 4, :level => :h )
    png = qr.to_img
    temp_img_name = "public/pdf/#{self.id.to_s}.png"
    png.resize(78, 78).save(temp_img_name)
    pdf = Prawn::Document.new(:page_size => 'B5', margin: 0)
    pdf.font("public/fonts/weiruanyahei.ttf") do
      pdf.draw_text local_course.course.name, at: [32.mm, 178.mm], size: 30
      pdf.draw_text self.name, at: [56.mm, 68.mm], size: 24
      pdf.draw_text local_course.number, at: [56.mm, 48.mm], size: 24
      pdf.image "public/pdf/#{self.id.to_s}.png", at: [125.mm, 73.mm]
    end
    pdf.render_file "public/pdf/#{self.id.to_s}.pdf"
    "/pdf/#{self.id.to_s}.pdf"
  end

  def update_student(student)
    self.update_attributes({
      name: student["name"],
        email: student["email"],
        mobile: student["mobile"],
        city: student["city"],
        school_name: student["school_name"],
        phase: student["phase"],
        entrance_year: student["entrance_year"],
        student_number: student["student_number"],
        parent_name: student["parent_name"],
        parent_mobile: student["parent_mobile"]
    })
    true
  end

  def update_studies(study_ary)
    studey_ary.each do |s|
      study = self.studies.where(course_id: s["course_id"]) || self.studies.create(course_id: s["course_id"])
      study.update_attributes({
        lesson_id: s["lesson_id"],
        video_id: s["video_id"],
        time: s["time"]
      })
    end
  end

  def student_course_id_str
    self.student_local_courses.map do |e|
      e.course.id.to_s
    end .join(',')
  end

  def completed_lesson_id_str
    self.student_answers.map do |e|
      e.homework.lesson.try(:id).to_s
    end .join(',')
  end

  def list_my_teachers
    teachers_info = self.klasses.map { |e| e.teacher } .uniq.map { |t| t.teacher_info_for_student }
    { success: true, teachers: teachers_info }
  end

  def teacher_info_for_student(with_classes = false)
    info = {
      id: self.id.to_s,
      name: self.name.to_s,
      subject: self.subject,
      school: self.school.try(:name).to_s,
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
    self.notes.desc(:created_at).map { |e| [e.id.to_s, e.updated_at.to_i] }
  end

  def add_note_without_update(qid, hid)
    note = self.notes.where(question_id: qid, homework_id: hid).first
    if note.blank?
      note = Note.create_new(qid, hid, "", "", "")
      self.notes << note
    end
    self.set_note_update_time(note.subject)
    return note
  end

  def add_note(qid, hid, summary = "", tag = "", topics = "")
    note = self.notes.where(question_id: qid, homework_id: hid).first
    if note.present?
      note.update_note(summary, tag, topics)
    else
      note = Note.create_new(qid, hid, summary, tag, topics)
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
        "image_path" => n.image_path,
        "content" => n.content,
        "items" => n.items,
        "has_answer" => has_answer,
        "has_note" => has_note
      }
      if has_answer
        if n.real_homework.blank? || (n.real_homework.answer_time_type == "now" || (n.real_homework.answer_time_type == "later" && n.real_homework.answer_time < Time.now.to_i))
          note.merge!({ "answer" => n.answer || -1, "answer_content" => n.answer_content || [] })
        else
          note.merge!({ "answer" => -1, "answer_content" => [] })
        end
      end
      if has_note.to_s == "true"
        note.merge!({ "tag" => n.tag, "topics" => n.topic_str.split(','), "summary" => n.summary })
      end
      notes << note
    end
    response = User.post("/ExportNote.aspx",
      :body => {notes: notes.to_json} )
    filepath = response.body
    download_path = "public/documents/export-#{SecureRandom.uuid}.docx"

    open(download_path, 'wb') do |file|
      file << open("#{Rails.application.config.word_host}/#{URI.encode filepath}").read
    end
    ExportNoteEmailWorker.perform_async(email, download_path) if email.present?
    URI.encode(download_path[download_path.index('/')+1..-1])
  end

  def move_to(old_klass, new_klass_id)
    self.klasses.delete(old_klass)
    new_klass = Klass.find(new_klass_id)
    self.klasses << new_klass
  end

  def copy_to(klass_id)
    klass = Klass.find(klass_id)
    self.klasses << klass if !self.klasses.include?(klass)
  end

  def delete_from_class(klass)
    self.classes.delete(klass) and return if klass.default
    teacher = klass.teacher
    other_classes = teacher.classes.where(:id.ne => klass.id)
    the_other_class = teacher.classes.where(default: true).first
    other_students = other_classes.map { |e| e.students }
    the_other_class.students << self if !other_students.include?(self)
    self.klasses.delete(klass)
  end


  def tablet_student_finish_register(name, city, school, grade)
    self.update_attributes({
      name: name,
      city: city,
      school: school,
      grade: grade
    })
  end

  def local_course_id_ary
    self.student_local_courses.map { |e| e.id.to_s } .join(',')
  end
end
