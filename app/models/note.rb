# encoding: utf-8
class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  field :comment, type: String
  belongs_to :user
  belongs_to :question

  def self.create_new(qid, comment)
    n = Note.create(comment: comment)
    q = Question.find(qid)
    q.notes << n
    n
  end
end
