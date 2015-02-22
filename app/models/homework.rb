# encoding: utf-8
require 'httparty'
class Homework < Node
  field :subject, type: Integer
  field :q_ids, type: Array, default: []
  field :tag_set, type: String, default: "不懂,不会,不对,典型题"
  # no, now, and later
  field :answer_time_type, type: String, default: "no"
  field :answer_time, type: Integer
  has_and_belongs_to_many :questions, class_name: "Question", inverse_of: :homeworks
  has_one :compose
  has_many :notes

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  def self.create_by_name(name, subject)
    name_ary = name.split('.')
    name = name_ary[0..-2].join('.') if %w{doc docx}.include?(name_ary[-1])
    Homework.create(name: name, subject: subject)
  end

  def questions_in_order
    self.q_ids.map { |e| Question.find(e) }
  end

  def add_question(question)
    self.q_ids << q.id.to_s
    self.questions << q
    self.save
  end

  def add_questions(questions)
    questions.each do |q|
      self.q_ids << q.id.to_s
      self.questions << q
    end
    self.save
  end

  def replace_question(replace_question_id, question)
    self.questions.delete(Question.find(replace_question_id))
    index = self.q_ids.index(replace_question_id)
    self.q_ids[index] = question.id.to_s
    self.save
  end

  def insert_questions(before_question_id, questions)
    index = self.q.q_ids.index(before_question_id) + 1
    questions.reverse.each do |q|
      self.q_ids.insert(index, q.id.to_s)
      self.questions << q
    end
    self.save
  end

  def delete_question_by_index(index)
    self.q_ids.delete_at(index)
    self.save
  end

  def delete_question_by_id(qid)
    self.q_ids.delete(qid)
    self.save
  end

  def insert_question(index, q)
    if index != -1
      self.q_ids.insert(index.to_i, q.id.to_s)
    else
      self.q_ids = [q.id.to_s] + self.q_ids
    end
    self.questions << q if !self.questions.include?(q)
  end

  def generate(qr_code)
    questions = []
    self.questions_in_order.each do |q|
      link = MongoidShortener.generate("#{self.id.to_s},#{q.id.to_s}")
      questions << {"type" => q.type, "image_path" => q.image_path, "content" => q.content, "items" => q.items, "link" => link}
    end
    data = {
      "questions" => questions,
      "name" => self.name,
      "qrcode_host" => Rails.application.config.server_host,
      "doc_type" => "word",
      "qr_code" => qr_code
    }
    binding.pry
    response = Homework.post("/Generate.aspx",
      :body => {data: data.to_json} )
    return response.body
  end

  def self.list_all
    self.desc(:updated_at).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def self.list_recent(amount = 20)
    self.desc(:updated_at).limit(amount).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def format_answer_time
    if self.answer_time.blank?
      ""
    else
      Time.at(self.answer_time).strftime("%Y-%m-%d")
    end
  end

  def last_update_time
    self.updated_at.today? ? self.updated_at.strftime("%H点%M分") : self.updated_at.strftime("%Y年%m月%d日")
  end

  def self.parse_exam
    Dir["public/papers/*"].each do |path|
      name = path.split("/")[-1]
      @name = name
      next if name.start_with?("done")
      f = File.open(path)
      c = f.read
      f.close
      p = Nokogiri::HTML(c)
      name = p.css("h1").text
      h = Homework.create(name: name)
      parts = p.css(".part")
      parts.each do |part|
        title = part.css(".part_title").text
        if title.present?
          q = Question.create(type: "text", content: title)
          h.add_question(q)
        end
      end
    end
  end
end
