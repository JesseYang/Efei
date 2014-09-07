# encoding: utf-8
class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :subject, type: Integer
  field :user_create, type: Boolean, default: true

  has_and_belongs_to_many :notes

  def self.find_or_create(name, subject)
    t = Topic.where(name: name, subject: subject).first
    return t if t.present?
    return Topic.create(name: name, subject: subject)
  end
end
