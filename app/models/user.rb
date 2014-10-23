# encoding: utf-8
require 'open-uri'
require 'err_code'
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String, default: ""
  field :mobile, type: String, default: ""
  field :password, type: String, default: ""


  field :admin, :type => Boolean, :default => false
  field :name, :type => String, :default => ""
  field :school_admin, :type => Boolean, :default => false
  field :teacher, :type => Boolean, :default => false
  field :subject, :type => Integer
  field :grade, :type => Integer

  has_many :homeworks, class_name: "Homework", inverse_of: :user
  has_many :notes
  has_many :papers
  has_and_belongs_to_many :shared_homeworks, class_name: "Homework", inverse_of: :visitors
  belongs_to :school, class_name: "School", inverse_of: :teachers

  has_many :classes, class_name: "Klass", inverse_of: :teacher
  has_and_belongs_to_many :klasses, class_name: "Klass", inverse_of: :students

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json


  def self.find_by_auth_key(auth_key)
    user_id = Encryption.decrypt_auth_key(auth_key)
    User.where(id: user_id).first
  end

  def self.create_new_user(email_mobile, password, name)
    logger.info "AAAAAAAAAAAAAAAAAA"
    logger.info email_mobile.inspect
    logger.info "AAAAAAAAAAAAAAAAAA"
    u = User.where(email: email_mobile).first || User.where(mobile: email_mobile).first
    logger.info "AAAAAAAAAAAAAAAAAA"
    logger.info u.inspect
    logger.info "AAAAAAAAAAAAAAAAAA"
    return ErrCode.ret_false(ErrCode::USER_EXIST) if u.present?
    u = User.create(email: email_mobile, password: Encryption.encrypt_password(password), name: name)
    return { success: true, auth_key: Encryption.encrypt_auth_key(u.id.to_s) }
  end

  def self.login(email_mobile, password)
    u = User.where(email: email_mobile).first || User.where(mobile: email_mobile).first
    return ErrCode.ret_false(ErrCode::USER_NOT_EXIST) if u.blank?
    return ErrCode.ret_false(ErrCode::WRONG_PASSWORD) if u.password != Encryption.encrypt_password(password)
    return { success: true, auth_key: Encryption.encrypt_auth_key(u.id.to_s) }
  end

  def self.reset_password(key, password)
    password_info = Encryption.decrypt_activate_key(CGI::unescape(key))
    email = password_info.split(',')[0]
    u = User.where(email: email).first
    u.password = Encryption.encrypt_password(password)
    u.save
    return { success: true, auth_key: Encryption.encrypt_auth_key(u.id.to_s) }
  end

  def email_for_short
    if self.email.length < 20
      self.email
    else
      self.email[0..19] + "..."
    end
  end

  def list_notes(note_type, subject, created_at, keyword)
    notes = self.notes.where(:created_at.gt => Time.at(created_at))
    if keyword.present?
      notes = notes.any_of({question_str: /#{keyword}/}, {topic_str: /#{keyword}/}, {summary: /#{keyword}/}) 
    end
    notes = notes.select { |e| e.question.homework.subject == subject } if subject != 0
    notes = notes.select { |e| e.note_type == note_type } if note_type != 0
    notes
  end

  def list_question_in_note(subject, created_at)
    questions = self.notes.where(:created_at.gt => Time.at(created_at)).map { |e| e.question }
    questions = questions.select { |e| e.subject == subject } if subject != 0
  end

  def has_question_in_note?(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    (self.notes.map { |e| e.question_id.to_s }).include?(qid)
  end

  def add_question_to_note(q_or_qid, summary, note_type, topics)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    note = self.notes.where(question_id: qid).first
    if note.present?
      note.update_note(summary, note_type, topics)
      return note.id.to_s
    else
      note = Note.create_new(qid, summary, note_type, topics)
      self.notes << note
      return note.id.to_s
    end
  end

  def rm_question_from_note(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    n = self.notes.where(question_id: qid)
    n.destroy
    self.save
  end

  def has_question_in_paper?(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    paper = self.papers.cur.first || self.papers.create
    paper.question_ids.include?(qid)
  end

  def add_question_to_paper(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    paper = self.papers.cur.first || self.papers.create
    paper.question_ids << qid if !self.has_question_in_paper?(qid)
    paper.save
  end

  def rm_question_from_paper(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    paper = self.papers.cur.first || self.papers.create
    paper.question_ids.delete(qid)
    paper.save
  end

  def export_note(note_id_str, has_answer, has_note, send_email, email)
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
        note.merge!({ "note_type" => n.note_type, "topics" => n.topics.map { |e| e.name }, "summary" => n.summary })
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
    if send_email
      ExportNoteEmailWorker.perform_async(email, download_path)
    end
    URI.encode(download_path[download_path.index('/')+1..-1])
  end

  def self.batch_create_teacher(user, csv_str)
    CSV.generate do |re_csv|
      CSV.parse(csv_str, :headers => true) do |row|
        if User.where(email: row[2]).present?
          re_csv << [row[0], row[1], row[2], row[3], "邮箱已存在"]
          next
        end
        if Subject::CODE[row[0]].nil?
          re_csv << [row[0], row[1], row[2], row[3], "不存在#{row[0]}学科（支持学科包括：语文，数学，英语，物理，化学，生物，历史，政治，其他 ）"]
          next
        end
        t = User.new(name: row[1], email: row[2], subject: Subject::CODE[row[0]], password: row[3])
        t.school = user.school
        t.save(validate: false)
        re_csv << [row[0], row[1], row[2], row[3], "添加成功"]
      end
    end
  end

  def colleagues
    return [] if !self.teacher
    return User.where(school_id: self.school_id, subject: self.subject).where(:id.ne => self.id).desc(:name)
  end


  def teacher_info(subject = false)
    return "" if !self.teacher
    subject ? "#{self.school.name} #{Subject::NAME[self.subject]} #{self.name}" : "#{self.school.name} #{self.name}"
  end

  def self.teacher_info(subject)
    teachers = User.where(teacher: true, subject: subject)
    retval = { "请选择" => "" }
    teachers.each do |t|
      retval[t.teacher_info] = t.id.to_s
    end
    retval
  end

  def add_to_default_class(student)
    return if self.has_student?(student)
    default_class = self.classes.where(default: true).first || self.classes.create(default: true, name: "默认班级")
    default_class.students << student
  end

  def remove_student(student)
    self.classes.each do |c|
      c.students.delete(student)
    end
  end

  def has_student?(student)
    all_students_id = self.classes.map { |e| e.students.map { |stu| stu.id.to_s } } .flatten
    all_students_id.include?(student.id.to_s)
  end

  def has_teacher?(teacher)
    teacher.has_student?(self)
  end

  def teachers(subject)
    teachers = self.klasses.map { |e| e.teacher } .uniq
    teachers = teachers.select { |e| e.subject == subject }
  end
end
