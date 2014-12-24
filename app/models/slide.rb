# encoding: utf-8
require 'httparty'
class Slide < Node
  field :subject, type: Integer
  field :page_ids, type: Array, default: []
  # belongs_to :user, class_name: "User", inverse_of: :slides
  # belongs_to :folder, class_name: "Folder", inverse_of: :slides

  include HTTParty
  base_uri Rails.application.config.slides_host
  format  :json

  def self.create_by_name(name, subject)
    name_ary = name.split('.')
    name = name_ary[0..-2].join('.') if %w{ppt pptx}.include?(name_ary[-1])
    Slide.create(name: name, subject: subject)
  end

  def self.list_all
    self.desc(:updated_at).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def self.list_recent(amount = 20)
    self.desc(:updated_at).limit(amount).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def self.search(keyword)
    self.where(name: /#{keyword}/).map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def self.list_starred
    self.starred.map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
    end
  end

  def self.list_trash
    self.trashed.map do |h|
      {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject]
      }
    end
  end

  def last_update_time
    self.updated_at.today? ? self.updated_at.strftime("%H点%M分") : self.updated_at.strftime("%Y年%m月%d日")
  end
end
