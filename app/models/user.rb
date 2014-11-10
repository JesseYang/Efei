# encoding: utf-8
require 'open-uri'
require 'err_code'
require 'string'
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # user basic info
  field :email, type: String, default: ""
  field :mobile, type: String, default: ""
  field :name, type: String, default: ""
  field :password, type: String, default: ""

  # for restting email
  field :new_email, type: String, default: ""
  field :reset_password_verify_code, type: String, default: ""
  field :reset_password_token, type: String, default: ""

  # for restting mobile
  field :new_mobile, type: String, default: ""
  field :reset_mobile_verify_code, type: String, default: ""
  field :reset_mobile_expire_time, type: Integer

  # role
  field :admin, type: Boolean, default: false
  field :school_admin, type: Boolean, default: false

  # for teachers
  field :teacher, type: Boolean, default: false
  field :subject, type: Integer
  field :teacher_desc, type: String
  field :tag_sets, type: Array, default: []
  has_many :homeworks, class_name: "Homework", inverse_of: :user
  belongs_to :school, class_name: "School", inverse_of: :teachers
  has_many :classes, class_name: "Klass", inverse_of: :teacher

  # for students
  field :note_update_time, type: Hash, default: {}
  has_many :notes
  has_and_belongs_to_many :klasses, class_name: "Klass", inverse_of: :students

  has_many :feedbacks

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  ### Begin region: account operations
  def self.find_by_auth_key(auth_key)
    info = Encryption.decrypt_auth_key(auth_key)
    user_id = info.split(',')[0]
    User.where(id: user_id).first
  end

  def self.find_by_email_mobile(email_mobile)
    return nil if email_mobile.blank?
    if email_mobile.is_mobile?
      u = User.where(mobile: email_mobile).first
    else
      u = User.where(email: email_mobile).first
    end
    u
  end

  def generate_auth_key
    info = "#{self.id.to_s},#{Time.now.to_i}"
    Encryption.encrypt_auth_key(info)
  end

  def self.create_new_user(email_mobile, password, name)
    return ErrCode.ret_false(ErrCode::BLANK_EMAIL_MOBILE) if email_mobile.blank?
    u = User.where(email: email_mobile).first || User.where(mobile: email_mobile).first
    return ErrCode.ret_false(ErrCode::USER_EXIST) if u.present?
    if email_mobile.is_mobile?
      u = User.create(mobile: email_mobile, password: Encryption.encrypt_password(password), name: name)
    else
      u = User.create(email: email_mobile, password: Encryption.encrypt_password(password), name: name)
    end
    return { success: true, auth_key: u.generate_auth_key }
  end

  def self.login(email_mobile, password)
    return ErrCode.ret_false(ErrCode::BLANK_EMAIL_MOBILE) if email_mobile.blank?
    u = User.where(email: email_mobile).first || User.where(mobile: email_mobile).first
    return ErrCode.ret_false(ErrCode::USER_NOT_EXIST) if u.blank?
    return ErrCode.ret_false(ErrCode::WRONG_PASSWORD) if u.password != Encryption.encrypt_password(password)
    return { success: true, auth_key: u.generate_auth_key }
  end

  def send_reset_password_code
    self.reset_password_verify_code = "111111"
    self.reset_password_token = self.generate_auth_key
    self.save
    # TODO: send the sms
  end

  def self.app_reset_password(reset_password_token, password)
    info = Encryption.decrypt_auth_key(reset_password_token)
    uid, time = *info.split(",")
    u = User.where(id: uid).first
    return ErrCode.ret_false(ErrCode::WRONG_TOKEN) if u.nil?
    return ErrCode.ret_false(ErrCode::EXPIRED) if Time.now.to_i - time.to_i > Rails.application.config.expire_time
    u.update_attributes(password: Encryption.encrypt_password(password))
    return { success: true }
  end

  def self.reset_password(key, password)
    password_info = Encryption.decrypt_activate_key(CGI::unescape(key))
    email = password_info.split(',')[0]
    u = User.where(email: email).first
    u.password = Encryption.encrypt_password(password)
    u.save
    return { success: true, auth_key: u.generate_auth_key }
  end

  def email_for_short
    if self.email.length < 20
      self.email
    else
      self.email[0..19] + "..."
    end
  end

  def rename(name)
    self.update_attributes(name: name)
    return
  end

  def change_password(password, new_password)
    if self.password != Encryption.encrypt_password(password)
      return ErrCode.ret_false(ErrCode::WRONG_PASSWORD)
    end
    self.update_attributes(password: Encryption.encrypt_password(new_password))
    return
  end

  def change_email(email)
    if User.where(email: email).first.present?
      return ErrCode.ret_false(ErrCode::USER_EXIST)
    end
    self.update_attributes(new_email: email)
    # TODO: send an email to the email address, with a link and a key as the link parameter. The key should contains the email address, the user id, and the time information
    ResetEamilWorker.perform_async(self, email)
    return
  end

  def verify_email(key)
    info = Encryption.decrypt_reset_email_key(key)
    uid, email, time = *info.split(",")
    u = User.where(uid: uid).first
    return ErrCode.ret_false(ErrCode::WRONG_TOKEN) if u.blank?
    return ErrCode.ret_false(ErrCode::WRONG_TOKEN) if u.new_email != email
    return ErrCode.ret_false(ErrCode::EXPIRED) if Time.now.to_i - time.to_i > Rails.application.config.email_expire_time
    u.email = email
    u.new_email = nil
    u.save
    return { success: ture }
  end

  def change_mobile(mobile)
    if User.where(mobile: mobile).first.present?
      return ErrCode.ret_false(ErrCode::USER_EXIST)
    end
    self.reset_mobile_verify_code = "111111"
    self.new_mobile = mobile
    self.reset_mobile_expire_time = Time.now.to_i + Rails.application.config.expire_time
    self.save
    # TODO: send the sms
    return
  end

  def verify_mobile(code)
    if self.reset_mobile_verify_code != code
      return ErrCode.ret_false(ErrCode::WRONG_VERIFY_CODE)
    end
    self.mobile = new_mobile
    self.reset_mobile_verify_code = ""
    self.new_mobile = ""
    self.reset_mobile_expire_time = nil
    self.save
    return
  end
  ### End region: account operations

  ### Begin region: common operations
  def create_feedback(content)
    f = Feedback.create(content: content, user_id: self.id.to_s)
  end
  ### End region: common operations

  ### Begin region: teachers' operations
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
      info[:classes] << {
        id: c.id.to_s,
        id: c.name,
        id: c.desc
      } if c.visible
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

  def update_note(nid, summry, tag, topics)
    note = self.notes.find(nid)
    return if note.nil?
    note.update_note(summary, tag, topics)
    self.set_note_update_time(note.subject)
    return note
  end

  def rm_note(nid)
    note = self.notes.find(id: nid)
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
  ### End region: account operations

  ### Begin region: school admin operations
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
  ### End region: school admin operations

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

  ### Begin region: teachers' operations
  def add_to_class(class_id, student)
    return if self.has_student?(student)
    klass = self.classes.where(id: class_id).first || self.classes.where(default: true).first || self.classes.create(default: true, name: "默认班级")
    klass.students << student
    return { success: true }
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

  def create_tag_set(tag_set_str)
    new_tag_set = tag_set_str.split(/,|，/).map { |e| e.strip } .uniq
    self.tag_sets.each do |tag_set|
      if tag_set.sort == new_tag_set.sort
        return ErrCode.ret_false(ErrCode::TAG_EXIST)
      end
    end
    self.tag_sets << new_tag_set
    self.save
    return { success: true, tag_set: new_tag_set }
  end

  def update_tag_set(index, tag_set_str)
    new_tag_set = tag_set_str.split(/,|，/).map { |e| e.strip } .uniq
    self.tag_sets.each do |tag_set|
      if tag_set.sort == new_tag_set.sort
        return ErrCode.ret_false(ErrCode::TAG_EXIST)
      end
    end
    self.tag_sets[index] = new_tag_set
    self.save
    return { success: true, tag_set: new_tag_set }
  end

  def remove_tag_set(index, tag_set_str)
    self.tag_sets.delete(tag_set_str)
    { success: true }
  end
  ### End region: teachers' operations

  def teachers(subject)
    teachers = self.klasses.map { |e| e.teacher } .uniq
    teachers = teachers.select { |e| e.subject == subject }
  end
end
