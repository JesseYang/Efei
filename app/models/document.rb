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

  def parse(homework = nil)
    content = Document.get("/extract?filename=#{self.name}")
    groups = []
    questions = []
    cache = []
    content["content"].each do |para|
      next if para.start_with?("Evaluation Only")
      if para.is_separate? && questions.present?
        questions << parse_one_question(cache) if cache.length > 1
        cache = []
        groups << Group.create_by_questions(questions) if questions.present?
        questions = []
        next
      end
      if para.blank?
        questions << parse_one_question(cache) if cache.length > 1
        cache = []
        next
      end
      cache << para
    end
    questions << parse_one_question(cache) if cache.length > 1
    groups << Group.create_by_questions(questions) if questions.present?
    homework ||= Homework.create_by_name(self.name)
    homework.groups = groups
    homework.save
    homework
  end

  def parse_one_question(cache)
    if cache[-1].strip.start_with("答案") || cache[-1].strip.length == 1
      # the last line is answer
      answer = 0 if cache[-1].include? 'A'
      answer = 1 if cache[-1].include? 'B'
      answer = 2 if cache[-1].include? 'C'
      answer = 3 if cache[-1].include? 'D'
      cache = cache[0..-2]
    end
    content = cache[0..-2].join
    if cache[-1].scan(/A(.+)B(.+)C(.+)D(.*)/).present?
      # all items are in the last line
      items = cache[-1].scan(/A(.+)B(.+)C(.+)D(.*)/)[0].map do |e|
        e = e.slice(1..-1) if e.start_with?(".")
        e.strip
      end
    elsif cache[-2].scan(/A(.+)B(.+)/).present? && cache[-1].scan(/C(.+)D(.+)/).present?
      # four items are in two lines and two items each line
      items = []
      cache[-2].scan(/A(.+)B(.+)/)[0].each do |item|
        items << item.strip
      end
      cache[-1].scan(/C(.+)D(.+)/)[0].each do |item|
        items << item.strip
      end
    else
      # four items are in four lines
      items = []
      items << cache[-4].scan(/A(.+)/)[0][0].strip
      items << cache[-3].scan(/B(.+)/)[0][0].strip
      items << cache[-2].scan(/C(.+)/)[0][0].strip
      items << cache[-1].scan(/D(.+)/)[0][0].strip
    end
    Question.create_english_question(content, items, answer)
  end
end
