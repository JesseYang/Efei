# encoding: utf-8
require 'httparty'
class Compose
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  belongs_to :homework
  has_many :questions

  def add_question(question_id)
  	question = Question.find(question_id)
  	self.questions << question
  end

  def remove_question(question_id)
  	question = Question.find(question_id)
  	self.questions.delete(question)
  end
end
