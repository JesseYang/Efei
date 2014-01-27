#encoding: utf-8
class Group
  include Mongoid::Document
  include Mongoid::Timestamps
  field :random_select, type: Boolean,  default: true
  field :random_number, type: Integer, default: 1
  field :manual_select, type: Array, default: []
  has_and_belongs_to_many :questions
  belongs_to :homework

  def self.create_by_questions(questions)
    group = Group.create
    group.questions = questions
    group.save
    group
  end

  def select_style
    style = self.random_select ? "随机选择#{random_number}道题" : "手动选择#{manual_select.length}道题"
  end
end
