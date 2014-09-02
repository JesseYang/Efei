# encoding: utf-8
class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  # note 
  field :type, type: String
  field :subject, type: Integer
  field :content, type: Array, default: []
  field :items, type: Array, default: []
  field :preview, type: Boolean, default: true
  field :answer, type: Integer
  field :answer_content, type: Array, default: []
  field :inline_images, type: Array, default: []
  field :q_figures, type: Array, default: []
  field :a_figures, type: Array, default: []

  field :comment, type: String
  field :type, type: Integer
  belongs_to :user
  belongs_to :question
  has_and_belongs_to_many :topics

  def self.create_new(qid, comment)
    n = Note.create(comment: comment)
    q = Question.find(qid)
    q.notes << n
    n
  end
end
