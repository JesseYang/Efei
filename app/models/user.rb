# encoding: utf-8
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

  def list_question_in_note(subject, created_at)
    questions = self.notes.where(:created_at.gt => Time.at(created_at)).map { |e| e.question }
    questions = questions.select { |e| e.subject == subject } if subject != 0
  end

  def has_question_in_note?(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    (self.notes.map { |e| e.question_id.to_s }).include?(qid)
  end

  def add_question_to_note(q_or_qid, comment = "")
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    self.notes << Note.create_new(qid, comment) if !self.has_question_in_note?(qid)
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

  def export_note(has_answer, send_email, email)
    questions = []
    self.note.each do |note_q|
      q = Question.find(note_q["id"])
      questions << {
        "type" => q.type,
        "content" => q.content,
        "items" => q.items,
        "answer" => (has_answer ? q.answer : nil),
        "answer_content" => (has_answer ? q.answer_content : nil)
      }
    end
    response = User.post("/export_note",
      :body => { questions: questions, name: "错题本" }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    filename = JSON.parse(response.body)["filename"]
    ExportNoteEmailWorker.perform_async(email, "public/" + filename)
    filename
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
