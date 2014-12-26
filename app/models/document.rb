# encoding: utf-8
require 'httmultiparty'
require 'nkf'
require 'string'
class Document
  extend CarrierWave::Mount
  mount_uploader :document, DocumentUploader

  include HTTMultiParty
  base_uri Rails.application.config.word_host
  format  :json

  attr_accessor :name, :temp_name, :subject

  # http://www.aspose.com/docs/display/wordsjava/ImageType
  NO_IMAGE = 0
  UNKNOWN = 1
  EMF = 2
  WMF = 3
  PICT = 4
  JPEG = 5
  PNG = 6
  BMP = 7

  def parse_slide(subject)
    slide = Slide.create_by_name(self.name, subject)
    data = Document.post("/ParseSlides.aspx", :query => {
      ppt_file: File.new("public/#{self.document.to_s}")
    })
    if data[0] == false
      raise "wrong filetype"
    end
    slide.page_ids = data[1]
    slide.save
    slide
  end

  def parse_homework(subject, homework = nil)
    data = Document.post("/ParseWord.aspx", :query => {
      word_file: File.new("public/#{self.document.to_s}")
    })
    if data[0] == false
      raise "wrong filetype"
    end
    questions = []
    cache = []
    data[1].each do |ele|
      # convert full width char to half width char
      # ele = NKF.nkf('-X -w', ele).tr('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z') if ele.class == String
      # question separation
      if ele.class == String && ele.blank?
        questions << extract_one_question(subject, cache) if cache.length >= 1
        cache = []
        next
      end
      # parse para/table/image
      if ele.class == String
        if cache.blank?
          # this is the first line of this question, should remove the Number
          match = ele.strip.scan(/^例?[0-9]{0,2}\.?\s+(.*)$/)
          ele = match[0][0] if match[0].present?
        end
        cache << ele
      elsif ele.class == Hash || ele["type"] == "table"
        cache << ele
      end
    end
    questions << extract_one_question(subject, cache) if cache.length >= 1
    homework ||= Homework.create_by_name(self.name, subject)
    homework.add_questions(questions)
    homework
  end

  def parse_one_question(subject)
    content = Document.post("/ParseWord.aspx", :query => {
      file: File.new("public/#{self.document.to_s}")
    })

    cache = []
    content.each do |ele|
      next if ele.class == String && ele.blank?
      cache << ele
    end
    question = extract_one_question(subject, cache)
    return question
  end

  def parse_multiple_questions(subject)
    content = Document.post("/ParseWord.aspx", :query => {
      file: File.new("public/#{self.document.to_s}")
    })

    questions = []
    cache = []
    content.each do |ele|
      if ele.class == String && ele.blank?
        questions << extract_one_question(subject, cache) if cache.length >= 1
        cache = []
        next
      end
      cache << ele
    end
    questions << extract_one_question(subject, cache) if cache.length >= 1
    return questions
  end

  def extract_one_question(subject, cache)
    # 1. separate answer and question if there is answer
    answer_index = cache.index do |e|
      e.class == String && e.strip.match(/^[解|答|案|析]{1,2}[\:|：|\.| ].*/)
    end
    q_part = answer_index.nil? ? cache : cache[0..answer_index - 1]
    a_part = answer_index.nil? ? [] : cache[answer_index..- 1]

    q_part_figures = []
    q_part_text = []
    a_part_figures = []
    a_part_text = []

    q_part.each do |e|
      next if e.blank?
      if e.class == String && e.start_with?("$$fig_")
        q_part_figures << e
      else
        q_part_text << e
      end
    end

    a_part.each do |e|
      next if e.blank?
      if e.class == String && e.start_with?("$$fig_")
        a_part_figures << e
      else
        a_part_text << e
      end
    end

    # 2. judge the type of the question and parse the question
    q_part_text = q_part_text.select { |e| e.present? }
    if q_part_text[-1].class == String && q_part_text[-1].scan(/A(.+)[(（\s]B(.+)[(（\s]C(.+)[(（\s]D(.*)/).present?
      # all items are in the last line
      q_type = "choice"
      items = q_part_text[-1].scan(/[(（]?A[)）]?\s*[\.．:：]?(.+)[^(（][(（]?B[)）]?\s*[\.．:：]?(.+)[^(（][(（]?C[)）]?\s*[\.．:：]?(.+)[^(（][(（]?D[)）]?\s*[\.．:：]?(.*)/)[0].map do |e|
        e = e.slice(0..-2) if e.start_with?(".")
        e.strip
      end
      if q_part_text.length == 1
        # the content and the items are in one line
        content = [q_part_text[0][0..q_part_text[0].index(/A\s*[\.．:：]?(.+)B\s*[\.．:：]?(.+)C\s*[\.．:：]?(.+)D\s*[\.．:：]?(.*)/) - 1]]
      else
        content = q_part_text[0..-2]
      end
    elsif q_part_text[-2].class == String && q_part_text[-1].class == String && q_part_text[-2].scan(/^\s*[(（]?A[)）]?(.+)B(.+)/).present? && q_part_text[-1].scan(/^\s*[(（]?C[)）]?(.+)D(.+)/).present?
      # four items are in two lines and two items each line
      q_type = "choice"
      items = []
      q_part_text[-2].scan(/^\s*[(（]?A[)）]?\s*[\.．:：]?(.+)\s+[(（]?B[)）]?\s*[\.．:：]?(.+)/)[0].each do |item|
        items << item.strip
      end
      q_part_text[-1].scan(/^\s*[(（]?C[)）]?\s*[\.．:：]?(.+)\s+[(（]?D[)）]?\s*[\.．:：]?(.+)/)[0].each do |item|
        items << item.strip
      end
      content = q_part_text[0..-3]
    elsif q_part_text[-4].class == String && q_part_text[-3].class == String && q_part_text[-2].class == String && q_part_text[-1].class == String && q_part_text[-4].scan(/^\s*[(（]?A[)）]?(.+)/).present? && q_part_text[-3].scan(/^\s*[(（]?B[)）]?(.+)/).present? && q_part_text[-2].scan(/^\s*[(（]?C[)）]?(.+)/).present? && q_part_text[-1].scan(/^\s*[(（]?D[)）]?(.+)/).present?
      # four items are in four lines
      q_type = "choice"
      items = []
      items << q_part_text[-4].scan(/^\s*[(（]?A[)）]?\s*[\.．:：]?(.+)/)[0][0].strip
      items << q_part_text[-3].scan(/^\s*[(（]?B[)）]?\s*[\.．:：]?(.+)/)[0][0].strip
      items << q_part_text[-2].scan(/^\s*[(（]?C[)）]?\s*[\.．:：]?(.+)/)[0][0].strip
      items << q_part_text[-1].scan(/^\s*[(（]?D[)）]?\s*[\.．:：]?(.+)/)[0][0].strip
      content = q_part_text[0..-5]
    else
      q_type = "analysis"
      content = q_part_text
    end
    # 3. parse the answer
    answer, answer_content = *extract_answer(a_part_text, q_type)
    # create the question object
    if q_type == "choice"
      q = Question.create_choice_question(content, items, answer, answer_content, q_part_figures, a_part_figures)
    else
      q = Question.create_analysis_question(content, answer_content, q_part_figures, a_part_figures)
    end
    q
  end

  def extract_answer(a_part, q_type)
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
    [answer, answer_content]
  end
end
