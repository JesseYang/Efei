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
    content = cache[0..-2].join
    # items are always in the last line
    items = cache[-1].scan(/A(.+)B(.+)C(.+)D(.*)/)[0].map do |e|
      e = e.slice(1..-1) if e.start_with?(".")
      e.strip
    end
    Question.create_english_question(content, items)
  end
end
