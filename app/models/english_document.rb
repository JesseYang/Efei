# encoding: utf-8
require 'httparty'
require 'string'
class EnglishDocument < Document

  MAX_CHOICE_LINE = 8

  def parse(homework = nil)
    content = Document.get("/extract?filename=#{URI.encode(self.document.to_s.split('/')[-1])}")
    questions = []
    cache = []
    images = []
    content["content"].each do |ele|
      # ad added by aspose
      next if ele.class == String && ele.start_with?("Evaluation Only")
      # question separation
      if ele.class == String && ele.blank?
        questions << parse_one_question(cache, images) if cache.length >= 1
        cache = []
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
    @images = images
    questions << parse_one_question(cache) if cache.length > 1
    homework ||= Homework.create_by_name(self.name, Subject::MATH)
    homework.questions = questions
    homework.save
    homework
  end

  def parse_one_question(cache)
    # 1. separate answer and question if there is answer
    answer_index = cache.index do |e|
      e.class == String && e.strip.match(/^[解|答|案|析]{1,2}[\:|：|\.| ].+/)
    end
    q_part = answer_index.nil? ? cache : cache[0..answer_index - 1]
    a_part = answer_index.nil? ? nil : cache[answer_index..- 1]
    # 2. judge the type of the question and parse the question
    q_part = q_part.select { |e| e.present? }
    if q_part.length <= MAX_CHOICE_LINE
      # a choice question
      return parse_choice(q_part, a_part)
    end
    if q_part[-1].scan(/G(.+)/).present? && q_part[-2].scan(/F(.+)/).present? && q_part[-3].scan(/E(.+)/).present?
      # a reading_2 question
      parse_reading_2_question(q_part, a_part)
    end
    if q_part[-1].scan(/A(.+)B(.+)C(.+)D(.*)/).present? && q_part[-2].scan(/A(.+)B(.+)C(.+)D(.*)/)
      # a cloze question
      parse_cloze_question(q_part, a_part)
    end
    # a reading_1 question
  end

  def parse_choice(q_part, a_part)
    if q_part[-1].class == String && q_part[-1].scan(/A(.+)B(.+)C(.+)D(.*)/).present?
      # all items are in the last line
      q_type = "choice"
      items = q_part[-1].scan(/A\s*[\.．:：]?(.+)B\s*[\.．:：]?(.+)C\s*[\.．:：]?(.+)D\s*[\.．:：]?(.*)/)[0].map do |e|
        e = e.slice(1..-1) if e.start_with?(".")
        e.strip
      end
      if q_part.length == 1
        # the content and the items are in one line
        content = [q_part[0][0..q_part[0].index(/A\s*[\.．:：]?(.+)B\s*[\.．:：]?(.+)C\s*[\.．:：]?(.+)D\s*[\.．:：]?(.*)/) - 1]]
      else
        content = q_part[0..-2]
      end
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
    end
    # 3. parse the answer
    answer, answer_content = *parse_choice_answer(a_part)
    # create the question object
    Question.create_choice_question(content, items, answer, answer_content, @images)
  end

  def parse_choice_answer(a_part)
    if a_part.present?
      if a_part[0].class == String
        answer = 0 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*A.?/)
        answer = 1 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*B.?/)
        answer = 2 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*C.?/)
        answer = 3 if a_part[0].match(/^(解|答|案|析){1,2}[\:|：|\.| ]\s*D.?/)
      end
      # remove the answer alt
      match = a_part[0].scan(/^[解|答|案|析]{1,2}[\:|：|\.| ]\s*(.*)/)
      a_part[0] = match[0][0] if match[0].present?
      if %w{A B C D}.include?(a_part[0].strip)
        answer_content = a_part[1..-1]
      else
        answer_content = a_part
      end
    end
    [answer, answer_content]
  end

  def parse_cloze_question(q_part, a_part)
    sub_questions = []
    while q_part[-1].scan(/A(.+)B(.+)C(.+)D(.*)/).present?
      items = q_part[-1].scan(/A\s*[\.．:：]?(.+)B\s*[\.．:：]?(.+)C\s*[\.．:：]?(.+)D\s*[\.．:：]?(.*)/)[0].map do |e|
        e = e.slice(1..-1) if e.start_with?(".")
        e.strip
      end
      sub_questions << items
      q_part.delete_at(-1)
    end
    sub_questions.reverse!
    content = q_part
    answer = parse_cloze_answer(a_part)
    Question.create_cloze_question(content, sub_questions, answer, @images)
  end

  def parse_cloze_answer(a_part)
    return nil if a_part.blank?
  end

  def parse_reading_2_question(q_part, a_part)
    items = []
    items << q_part[-7].scan(/A\s*[\.．:：]?(.+)/)[0][0].strip
    items << q_part[-6].scan(/B\s*[\.．:：]?(.+)/)[0][0].strip
    items << q_part[-5].scan(/C\s*[\.．:：]?(.+)/)[0][0].strip
    items << q_part[-4].scan(/D\s*[\.．:：]?(.+)/)[0][0].strip
    items << q_part[-3].scan(/E\s*[\.．:：]?(.+)/)[0][0].strip
    items << q_part[-2].scan(/F\s*[\.．:：]?(.+)/)[0][0].strip
    items << q_part[-1].scan(/G\s*[\.．:：]?(.+)/)[0][0].strip
    content = q_part[0..-8]
    answer = parse_reading_2_answer(a_part)
    Question.create_reading_2_question(content, items, answer, @images)
  end

  def parse_reading_2_answer(a_part)
    return nil if a_part.blank?
  end
end
