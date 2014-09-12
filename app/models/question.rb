require 'rqrcode_png'
require 'open-uri'
require 'RMagick'
class Question
  include Mongoid::Document
  include Mongoid::Timestamps
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
  belongs_to :homework
  has_many :notes

  IMAGE_TYPE = %w{jpeg png jpg bmp}
  IMAGE_DIR = Rails.application.config.image_dir
  DOWNLOAD_URL = Rails.application.config.image_download_url

  include HTTParty
  base_uri Rails.application.config.convert_image_url

  before_destroy do |doc|
    # delete all images files
    doc.inline_images.each do |e|
      File.delete("#{IMAGE_DIR}/#{e}") if File.exist?("#{IMAGE_DIR}/#{e}")
    end
  end


  def self.create_choice_question(content, items, answer, answer_content, q_figures, a_figures)
    question = self.create(type: "choice",
      content: content,
      items: items,
      answer: answer,
      answer_content: answer_content || [],
      q_figures: q_figures,
      a_figures: a_figures)
  end

  def self.create_analysis_question(content, answer_content, q_figures, a_figures)
    question = self.create(type: "analysis",
      content: content,
      answer_content: answer_content || [],
      q_figures: q_figures,
      a_figures: a_figures)
  end

  def update_content(question_content, question_answer)
    tables = (self.content + self.answer_content ).select do |e|
      e.class == Hash && e["type"] == "table"
    end

    new_content = question_content.split(/\n|\r/).map do |line|
      if line.match(/table[0-9]+/)
        # table
        table_index = line.scan(/table([0-9]+)/)[0][0].to_i
        tables[table_index]
      else line.class == String
        # normal line
        tidyup_line = line
        line.scan(/\$([a-z 0-9]{8})\$/).each do |e|
          inline_images.each do |image|
            if image.start_with?(e[0])
              tidyup_line.gsub!(e[0], image)
              break
            end
          end
        end
        tidyup_line
      end
    end
    self.content = new_content

    new_answer_content = question_answer.split(/\n|\r/).map do |line|
      if line.match(/table[0-9]+/)
        # table
        table_index = line.scan(/table([0-9]+)/)[0][0].to_i
        tables[table_index]
      else line.class == String
        # normal line
        tidyup_line = line
        line.scan(/\$([a-z 0-9]{8})\$/).each do |e|
          inline_images.each do |image|
            if image.start_with?(e[0])
              tidyup_line.gsub!(e[0], image)
              break
            end
          end
        end
        tidyup_line
      end
    end
    self.answer_content = new_answer_content
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

  def figures
    if self.type == "choice"
      if self.q_figures.length >= 4
        return self.q_figures[0..-5]
      else
        return self.q_figures
      end
    else
      return self.q_figures
    end
  end

  def generate_qr_code
    if !File.exist?("public/qr_code/#{self.id.to_s}.png")
      link = MongoidShortener.generate(Rails.application.config.server_host + "/student/questions/#{self.id.to_s}")
      qr = RQRCode::QRCode.new(link, :size => 4, :level => :h )
      png = qr.to_img
      png.resize(90, 90).save("public/qr_code/#{self.id.to_s}.png")
    end
    "/qr_code/#{self.id.to_s}.png"
  end

  def item_len
    item_max_len = items.map { |e| e.length } .max
  end
end
