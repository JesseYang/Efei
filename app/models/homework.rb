# encoding: utf-8
require 'httparty'
class Homework
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::Trashable
  include Concerns::Starred
  field :name, type: String
  field :subject, type: Integer
  field :q_ids, type: Array, default: []
  field :tag_set, type: String, default: "不懂,不会,不对,典型题"
  has_many :questions, dependent: :destroy
  belongs_to :user, class_name: "User", inverse_of: :homework
  belongs_to :folder, class_name: "Folder", inverse_of: :homework

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

  def add_questions(questions)
    questions.each do |q|
      self.q_ids << q.id.to_s
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

  def generate
    questions = []
    self.questions_in_order.each do |q|
      link = MongoidShortener.generate(Rails.application.config.server_host + "/student/questions/#{q.id.to_s}")
      questions << {"type" => q.type, "content" => q.content, "items" => q.items, "link" => link, "figures" => q.q_figures}
    end
    data = {"questions" => questions, "name" => self.name, "qrcode_host" => Rails.application.config.server_host}
    puts data.inspect
    logger.info data
    response = Homework.post("/Generate.aspx",
      :body => {data: data.to_json} )
    return response.body
  end
end
