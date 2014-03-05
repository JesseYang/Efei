# encoding: utf-8
require 'httparty'
class Homework
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  belongs_to :user
  has_many :groups, dependent: :destroy

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  def self.create_by_name(name)
    name_ary = name.split('.')
    name = name_ary[0..-2].join('.') if %w{doc docx}.include?(name_ary[-1])
    Homework.create(name: name)
  end

  def questions
    (self.groups.map { |e| e.questions }).flatten
  end

  def export
    groups_data = []
    self.groups.asc(:created_at).each do |g|
      questions = []
      g.questions.asc(:created_at).each do |q|
        questions << {"type" => q.type,
          "content" => q.content,
          "items" => q.items,
          "answer" => q.answer,
          "answer_content" => q.answer_content}
      end
      groups_data << questions
    end
    response = Homework.post("/export",
      :body => { groups: groups_data, name: self.name }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return JSON.parse(response.body)["filename"]
  end

  def generate
    questions = []
    self.groups.each do |g|
      if g.random_select
        g.questions.shuffle[0..[g.questions.length, g.random_number].min-1].each do |q|
          link = "#{MongoidShortener.generate(Rails.application.config.server_host)}"
          questions << {"type" => q.type, "content" => q.content, "items" => q.items, "link" => link}
        end
      else
        g.manual_select.each do |qid|
          q = Question.find(qid)
          link = "#{MongoidShortener.generate(Rails.application.config.server_host)}"
          questions << {"type" => q.type, "content" => q.content, "items" => q.items, "link" => link}
        end
      end
    end
    response = Homework.post("/generate",
      :body => { questions: questions, name: self.name }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return JSON.parse(response.body)["filename"]
  end
end
