require 'rqrcode_png'
class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String
  field :items, type: Array, default: []
  field :preview, type: Boolean, default: true
  has_and_belongs_to_many :group

  def self.create_english_question(content, items)
    self.create(content: content, items: items)
  end
end
