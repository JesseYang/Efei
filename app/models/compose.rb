# encoding: utf-8
require 'httparty'
class Compose
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  belongs_to :homework
  has_and_belongs_to_many :questions, class_name: "Question", inverse_of: :composes

  def add_question(question_id)
  	question = Question.find(question_id)
  	self.questions.push(question)
  end

  def remove_question(question_id)
  	question = Question.find(question_id)
  	self.questions.delete(question)
  end
end
