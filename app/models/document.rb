# encoding: utf-8
require 'fileutils'
require 'zip'
require 'RMagick'
require 'httparty'
require 'string'
class Document
  extend CarrierWave::Mount
  mount_uploader :document, DocumentUploader

  include HTTParty
  base_uri 'http://localhost:9292'
  format  :json

  attr_accessor :name

  # http://www.aspose.com/docs/display/wordsjava/ImageType
  NO_IMAGE = 0
  UNKNOWN = 1
  EMF = 2
  WMF = 3
  PICT = 4
  JPEG = 5
  PNG = 6
  BMP = 6

  def parse(homework = nil)
    content = Document.get("/extract?filename=#{self.name}")
    groups = []
    questions = []
    cache = []
    images = []
    content["content"].each do |ele|
      # ad added by aspose
      next if ele.class == String && ele.start_with?("Evaluation Only")
      # group separation
      if ele.class == String && ele.is_separate? && questions.present?
        questions << parse_one_question(cache) if cache.length > 1
        cache = []
        groups << Group.create_by_questions(questions) if questions.present?
        questions = []
        next
      end
      # question separation
      if ele.class == String && ele.blank?
        questions << parse_one_question(cache, images) if cache.length > 1
        cache = []
        images = []
        next
      end
      # parse para/talbe/image
      if ele.class == String
        images += ele.convert_img_type
        cache << ele
      elsif ele.class == Hash || ele["type"] == "table"
        ele["content"].each do |row|
          row.each do |cell|
            cell.each do |para|
              images += para.convert_img_type
            end
          end
        end
        cache << ele
      elsif ele.class == Hash || ele["type"] == "image"
      end
    end
    questions << parse_one_question(cache, images) if cache.length > 1
    groups << Group.create_by_questions(questions) if questions.present?
    homework ||= Homework.create_by_name(self.name)
    homework.groups = groups
    homework.save
    homework
  end

  def parse_one_question(cache, images)
    # 1. separate answer and question if there is answer
    answer_index = cache.index do |e|
      e.class == String && e.strip.match(/^(解|答案)(\:|：| ).+/)
    end
    q_part = answer_index.nil? ? cache : cache[0..answer_index - 1]
    a_part = answer_index.nil? ? nil : cache[answer_index..- 1]
    # 2. judge the type of the question and parse the question
    q_part = q_part.select { |e| e.present? }
    if q_part[-1].class == String && q_part[-1].scan(/A(.+)B(.+)C(.+)D(.*)/).present?
      # all items are in the last line
      q_type = "choice"
      items = q_part[-1].scan(/A(.+)B(.+)C(.+)D(.*)/)[0].map do |e|
        e = e.slice(1..-1) if e.start_with?(".")
        e.strip
      end
      content = q_part[0..-2]
    elsif q_part[-2].class == String && q_part[-1].class == String && q_part[-2].scan(/A(.+)B(.+)/).present? && q_part[-1].scan(/C(.+)D(.+)/).present?
      # four items are in two lines and two items each line
      q_type = "choice"
      items = []
      q_part[-2].scan(/A(.+)B(.+)/)[0].each do |item|
        items << item.strip
      end
      q_part[-1].scan(/C(.+)D(.+)/)[0].each do |item|
        items << item.strip
      end
      content = q_part[0..-3]
    elsif q_part[-4].class == String && q_part[-3].class == String && q_part[-2].class == String && q_part[-1].class == String && q_part[-4].scan(/A(.+)/).present? && q_part[-3].scan(/B(.+)/).present? && q_part[-2].scan(/C(.+)/).present? && q_part[-1].scan(/D(.+)/).present?
      # four items are in four lines
      q_type = "choice"
      items = []
      items << q_part[-4].scan(/A(.+)/)[0][0].strip
      items << q_part[-3].scan(/B(.+)/)[0][0].strip
      items << q_part[-2].scan(/C(.+)/)[0][0].strip
      items << q_part[-1].scan(/D(.+)/)[0][0].strip
      content = q_part[0..-5]
    else
      q_type = "analysis"
      content = q_part
    end
    # 3. parse the answer
    if a_part.present?
      if q_type == "choice" && a_part[0].class == String
        answer = 0 if a_part[0].match(/^(解|答案)(\:|：| )\s*A.?/)
        answer = 1 if a_part[0].match(/^(解|答案)(\:|：| )\s*B.?/)
        answer = 2 if a_part[0].match(/^(解|答案)(\:|：| )\s*C.?/)
        answer = 3 if a_part[0].match(/^(解|答案)(\:|：| )\s*D.?/)
      end
      answer_content = a_part
    end
    # create the question object
    if q_type == "choice"
      q = Question.create_choice_question(content, items, answer, answer_content, images)
    else
      q = Question.create_analysis_question(content, answer_content, images)
    end
    q
  end
end
