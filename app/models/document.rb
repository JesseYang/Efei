# encoding: utf-8
require 'httparty'
require 'string'
class Document
  extend CarrierWave::Mount
  mount_uploader :document, DocumentUploader

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  attr_accessor :name, :temp_name

  # http://www.aspose.com/docs/display/wordsjava/ImageType
  NO_IMAGE = 0
  UNKNOWN = 1
  EMF = 2
  WMF = 3
  PICT = 4
  JPEG = 5
  PNG = 6
  BMP = 7

  def parse(homework = nil)
    content = Document.get("/extract?filename=#{URI.encode(self.document.to_s.split('/')[-1])}")
    groups = []
    questions = []
    cache = []
    images = []
    content["content"].each do |ele|
      # ad added by aspose
      next if ele.class == String && ele.start_with?("Evaluation Only")
      # group separation
      if ele.class == String && ele.is_separate? && questions.present?
        questions << parse_one_question(cache) if cache.length >= 1
        cache = []
        groups << Group.create_by_questions(questions) if questions.present?
        questions = []
        images = []
        next
      end
      # question separation
      if ele.class == String && ele.blank?
        questions << parse_one_question(cache, images) if cache.length >= 1
        cache = []
        ####################################################################
        # take question separation as group separation
        #   this hide the group function
        groups << Group.create_by_questions(questions) if questions.present?
        questions = []
        ####################################################################
        images = []
        next
      end
      # parse para/talbe/image
      if ele.class == String
        if cache.blank?
          # this is the first line of this question, should remove the Number
          match = ele.strip.scan(/^例?[0-9]{0,2}\.?\s+(.*)$/)
          ele = match[0][0] if match[0].present?
        end
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
      e.class == String && e.strip.match(/^[解|答|案|析]{1,2}[\:|：|\.| ].+/)
    end
    q_part = answer_index.nil? ? cache : cache[0..answer_index - 1]
    a_part = answer_index.nil? ? nil : cache[answer_index..- 1]
    # 2. judge the type of the question and parse the question
    q_part = q_part.select { |e| e.present? }
    if q_part[-1].class == String && q_part[-1].scan(/A(.+)B(.+)C(.+)D(.*)/).present?
      # all items are in the last line
      q_type = "choice"
      items = q_part[-1].scan(/A\s*[\.．:：]?(.+)B\s*[\.．:：]?(.+)C\s*[\.．:：]?(.+)D\s*[\.．:：]?(.*)/)[0].map do |e|
        e = e.slice(1..-1) if e.start_with?(".")
        e.strip
      end
      content = q_part[0..-2]
    elsif q_part[-2].class == String && q_part[-1].class == String && q_part[-2].scan(/A(.+)B(.+)/).present? && q_part[-1].scan(/C(.+)D(.+)/).present?
      # four items are in two lines and two items each line
      q_type = "choice"
      items = []
      q_part[-2].scan(/A\s*[\.．:：]?(.+)B\s*[\.．:：]?(.+)/)[0].each do |item|
        items << item.strip
      end
      q_part[-1].scan(/C\s*[\.．:：]?(.+)D\s*[\.．:：]?(.+)/)[0].each do |item|
        items << item.strip
      end
      content = q_part[0..-3]
    elsif q_part[-4].class == String && q_part[-3].class == String && q_part[-2].class == String && q_part[-1].class == String && q_part[-4].scan(/A(.+)/).present? && q_part[-3].scan(/B(.+)/).present? && q_part[-2].scan(/C(.+)/).present? && q_part[-1].scan(/D(.+)/).present?
      # four items are in four lines
      q_type = "choice"
      items = []
      items << q_part[-4].scan(/A\s*[\.．:：]?(.+)/)[0][0].strip
      items << q_part[-3].scan(/B\s*[\.．:：]?(.+)/)[0][0].strip
      items << q_part[-2].scan(/C\s*[\.．:：]?(.+)/)[0][0].strip
      items << q_part[-1].scan(/D\s*[\.．:：]?(.+)/)[0][0].strip
      content = q_part[0..-5]
    else
      q_type = "analysis"
      content = q_part
    end
    # 3. parse the answer
    if a_part.present?
      if q_type == "choice" && a_part[0].class == String
        answer = 0 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*A.?/)
        answer = 1 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*B.?/)
        answer = 2 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*C.?/)
        answer = 3 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*D.?/)
      end
      # remove the answer alt
      match = a_part[0].scan(/^[解|答|案|析]{1,2}[\:|：|\.| ]\s*(.*)/)
      a_part[0] = match[0][0] if match[0].present?
      if q_type == "choice" && %w{A B C D}.include?(a_part[0].strip)
        answer_content = a_part[1..-1]
      else
        answer_content = a_part
      end
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
