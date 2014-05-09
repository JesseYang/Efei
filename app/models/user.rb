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

  field :note, :type => Array, :default => []

  has_many :homeworks
  has_many :papers
  has_many :shares
  belongs_to :school, class_name: "School", inverse_of: :teachers

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  def has_question_in_note?(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    (self.note.map { |e| e["id"] }).include?(qid)
  end

  def add_question_to_note(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    self.note << { id: qid, top: false } if !self.has_question_in_note?(qid)
    self.save
  end

  def rm_question_from_note(q_or_qid)
    qid = (q_or_qid.is_a?(Question) ? q_or_qid.id.to_s : q_or_qid)
    self.note.delete_if { |e| e["id"] == qid }
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
      link = "#{MongoidShortener.generate(Rails.application.config.server_host)}"
      questions << {
        "type" => q.type,
        "content" => q.content,
        "items" => q.items,
        "link" => link,
        "answer" => (has_answer ? q.answer : nil),
        "answer_content" => (has_answer ? q.answer_content : nil)
      }
    end
    response = User.post("/generate",
      :body => { questions: questions, name: "错题本" }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    JSON.parse(response.body)["filename"]
  end


  def self.batch_create_teacher(user, csv)
    error_msg = []
    CSV.parse(csv_str, :headers => true) do |row|
      if User.where(email: row[2]).present?
        error_msg = row + ["邮箱已存在"]
      end
      if Subject::CODE[row[0]].nil?
        error_msg = row + ["不存在#{row[0]}学科（支持学科包括：语文，数学，英语，物理，化学，生物，历史，政治，其他 ）"]
      end
      t = User.new(name: row[1], email: row[2], subject: Subject::CODE[row[0]], password: "111111")
      t.school = user.school
      t.save(validate: false)
    end
    result = {error_msg: error_msg}
  end
end
