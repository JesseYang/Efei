# encoding: utf-8
require 'httparty'
require 'rqrcode_png'
require 'open-uri'
require 'string'
class Question
  include Magick
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String
  field :subject, type: Integer
  field :content, type: Array, default: []
  field :items, type: Array, default: []
  field :answer, type: Integer
  field :answer_content, type: Array, default: []
  field :image_path, type: String, default: "http://dev.image.efei.org/public/download/"
  field :difficulty, type: Integer
  field :external_site, type: String
  field :external_id, type: String
  has_and_belongs_to_many :homeworks, class_name: "Homework", inverse_of: :questions
  has_and_belongs_to_many :composes, class_name: "Compose", inverse_of: :questions
  belongs_to :user
  has_many :notes

  has_and_belongs_to_many :points, class_name: "Point", inverse_of: :questions

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
    # doc.inline_images.each do |e|
    #   File.delete("#{IMAGE_DIR}/#{e}") if File.exist?("#{IMAGE_DIR}/#{e}")
    # end
  end


  def self.create_choice_question(content, items, answer, answer_content)
    question = self.create(type: "choice",
      content: content,
      items: items,
      answer: answer,
      answer_content: (answer_content || []))
  end

  def self.create_analysis_question(content, answer_content)
    question = self.create(type: "analysis",
      content: content,
      answer_content: (answer_content || []))
  end

  def info_for_student
    {
      _id: self.id.to_s,
      subject: self.homework.subject,
      type: self.type,
      content: self.content,
      items: self.items,
      answer: self.answer,
      answer_content: self.answer_content,
      tag_set: self.homework.tag_set,
      image_path: self.image_path
    }
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
    item_max_len = items.map { |e| e.item_length } .max
  end

  def generate
    questions = []
    questions << {"type" => self.type, "content" => self.content, "items" => self.items}
    data = {
      "questions" => questions,
      "name" => "题目",
      "qrcode_host" => Rails.application.config.server_host,
      "doc_type" => "word",
      "qr_code" => false
    }
    response = Homework.post("/Generate.aspx",
      :body => {data: data.to_json} )
    return response.body
  end

  def self.import_material_questions
    type_hash = {
      "选择题" => "choice",
      "填空题" => "blank",
      "解答题" => "analysis"
    }
    item_hash = {
      "A" => 0,
      "B" => 1,
      "C" => 2,
      "D" => 3,
    }
    difficulty_ary = [-1, 0, 0, 1, 2, 2]
    Material.where(imported: false).each do |m|
      next if m.dangerous
      next if m.type == "选择题" && m.choice_without_items
      next if Question.where(external_site: "kuailexue.com", external_id: m.external_id).first.present?
      problem = false
      type = type_hash[m.type]
      content = m.content.map do |line|
        Question.process_material_line(line)
      end
      if content.include? "dangerous"
        m.update_attribute :dangerous, true
        next
      end
      answer_content = []
      if type == "choice"
        items = m.items.each_with_index.map do |e, i|
          if e.length > 1
            problem = true
            break
          end
          item_content = e[0].scan(/[ABCD]．(.+)/)[0][0]
          Question.process_material_line(item_content)
        end
        if items.include? "dangerous"
          m.update_attribute :dangerous, true
          next
        end
        answer = item_hash[m.answer[0]]
      else
        answer_content += (m.answer || []).map do |line|
          Question.process_material_line(line)
        end
      end
      answer_content += (m.answer_content || []).map do |line|
        Question.process_material_line(line)
      end
      if answer_content.include? "dangerous" || problem
        m.update_attribute :dangerous, true
        next
      end
      difficulty = difficulty_ary[m.difficulty]
      q = Question.create(
        subject: m.subject,
        type: type,
        external_site: "kuailexue.com",
        external_id: m.external_id,
        content: content,
        items: items,
        answer: answer,
        answer_content: answer_content,
        image_path: "#{Rails.application.config.server_host}/question_images/",
        difficulty: difficulty,
        subject: 2
      )
      m.tags.each do |t|
        p = ::Point.where(name: t["text"]).first
        next if p.blank?
        p.push_question(q)
      end
      m.update_attribute(:imported, true)
    end
  end

  def self.process_material_line(line)
    eles = line.split("$$")
    eles << "" if line.end_with?("$$")
    eles = eles.map do |e|
      if e.start_with?("equ_")
        image_id = SecureRandom.uuid
        tex = e[4..-1]
        File.open("public/question_images/#{image_id}.gif", "wb") do |fo|
          fo.write open(URI.escape("http://tex.efei.org/cgi-bin/mathtex.cgi?#{tex}")).read
        end
        image = ImageList.new("public/question_images/#{image_id}.gif")
        width = image.page.width
        height = image.page.height
        return "dangerous" if width == 217 && height == 56
        "fig_#{image_id}*gif*#{width}*#{height}"
      elsif e.start_with?("img_")
        image_id = SecureRandom.uuid
        tmp, image_type, filename = e.split(/\*|_/)
        FileUtils.cp("public/material_images/#{filename}.#{image_type}", "public/question_images/#{image_id}.#{image_type}")
        image = ImageList.new("public/question_images/#{image_id}.#{image_type}")
        width = image.page.width
        height = image.page.height
        return "dangerous" if width == 217 && height == 56
        "fig_#{image_id}*#{image_type}*#{width}*#{height}"
      else
        e
      end
    end
    eles.join("$$")
  end
end
