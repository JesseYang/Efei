# encoding: utf-8
require 'open-uri'
class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  # 1 for normal, 2 for deleted
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

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

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
end
