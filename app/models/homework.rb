# encoding: utf-8
require 'httparty'
class Homework
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :subject, type: Integer
  has_many :questions, dependent: :destroy
  belongs_to :user, class_name: "User", inverse_of: :homework
  has_and_belongs_to_many :visitors, class_name: "User", inverse_of: :shared_homeworks

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  def self.create_by_name(name, subject)
    name_ary = name.split('.')
    name = name_ary[0..-2].join('.') if %w{doc docx}.include?(name_ary[-1])
    Homework.create(name: name, subject: subject)
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
    self.questions.each do |q|
      link = "#{MongoidShortener.generate(Rails.application.config.server_host)}"
      questions << {"type" => q.type, "content" => q.content, "items" => q.items, "link" => link}
    end
    response = Homework.post("/generate",
      :body => { questions: questions, name: self.name }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return JSON.parse(response.body)["filename"]
  end

  def privilege_of(user)
    return "拥有" if self.user == user
    return "共享" if self.visitors.include?(user)
    return ""
  end
end
