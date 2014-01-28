# encoding: utf-8
require 'httparty'
class Homework
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  belongs_to :user
  has_many :groups

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
        questions << {"content" => q.content, "items" => q.items}
      end
      groups_data << questions
    end
    response = HTTParty.post("http://localhost:9292/export",
      :body => { groups: groups_data, name: self.name }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return JSON.parse(response.body)["filename"]
  end

  def generate
    questions = []
    self.groups.each do |g|
      if g.random_select
        g.questions.shuffle[0..[g.questions.length, g.random_number].min-1].each do |q|
          questions << {"content" => q.content, "items" => q.items, "link" => "http://www.google.com.hk"}
        end
      end
    end
    response = HTTParty.post("http://localhost:9292/generate",
      :body => { questions: questions, name: self.name }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    return JSON.parse(response.body)["filename"]
  end
end
