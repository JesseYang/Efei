require 'rqrcode_png'
class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String
  field :content, type: Array, default: []
  field :items, type: Array, default: []
  field :preview, type: Boolean, default: true
  field :answer, type: Integer
  field :answer_content, type: Array, default: []
  field :inline_images, type: Array, default: []
  belongs_to :group

  def self.create_choice_question(content, items, answer, answer_content, inline_images)
    question = self.create(type: "choice",
      content: content,
      items: items,
      answer:answer,
      answer: answer_content,
      inline_images: inline_images)
  end

  def self.create_analysis_question(content, answer_content, inline_images)
    question = self.create(type: "analysis",
      content: content,
      answer_content: answer_content,
      inline_images: inline_images)
  end

  def update_content(content)
    tidyup_content = content
    content.scan(/\$([a-z 0-9]{8})\$/).each do |e|
      inline_images.each do |image|
        if image.start_with?(e[0])
          tidyup_content.gsub!(e[0], image)
          break
        end
      end
    end
    self.content = tidyup_content
    self.save
  end

  def update_items(items)
    self.items = []
    items.each do |item|
      tidyup_item = item
      item.scan(/\$([a-z 0-9]{8})\$/).each do |e|
        inline_images.each do |image|
          if image.start_with?(e[0])
            tidyup_item.gsub!(e[0], image)
            break
          end
        end
      end
      self.items << tidyup_item
    end
    self.save
  end
end
