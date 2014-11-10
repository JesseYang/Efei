# encoding: utf-8
require 'httparty'
require 'rqrcode_png'
require 'open-uri'
# require 'RMagick'
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

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

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

  def info_for_student
    {
      id: self.id.to_s,
      subject: self.homework.subject,
      type: self.type,
      content: self.content,
      items: self.items,
      answer: self.answer,
      answer_content: self.answer_content,
      tag_set: self.homework.tag_set
    }
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

  def generate
    questions = []
    questions << {"type" => self.type, "content" => self.content, "items" => self.items, "figures" => self.q_figures}
    data = {"questions" => questions, "name" => "题目", "qrcode_host" => Rails.application.config.server_host}
    response = Homework.post("/Generate.aspx",
      :body => {data: data.to_json} )
    return response.body
  end
end
