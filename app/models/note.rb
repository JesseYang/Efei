# encoding: utf-8
class Note
  include Mongoid::Document
  include Mongoid::Timestamps

  # note should be a snapshoot of the original question
  field :subject, type: Integer
  field :type, type: String
  field :content, type: Array, default: []
  field :items, type: Array, default: []
  field :answer, type: Integer, default: -1
  field :answer_content, type: Array, default: []
  field :image_path, type: String, default: "http://dev.efei.org/public/download/"

  field :question_str, type: String, default: ""

  # tag set is copied from homework when note is created
  field :tag_set, type: String

  # note part
  field :topic_str, type: String, default: ""
  field :summary, type: String
  field :tag, type: String
  belongs_to :user
  belongs_to :question
  belongs_to :homework
  has_and_belongs_to_many :topics

  def update_note(summary, tag, topics)
    q = Question.find(self.question_id)
    self.update_attributes(type: q.type,
      content: q.content,
      items: q.items,
      answer: q.answer,
      answer_content: q.answer_content,
      summary: summary,
      tag: tag)
    self.topics.clear
    topics.split(',').each do |e|
      next if e.blank?
      t = Topic.find_or_create(e, self.subject)
      t.notes << self if t.present?
    end
    self.update_attributes({question_str: (self.content || []).join + (items || []).join,
      topic_str: self.topics.map { |e| e.name } .join(',') })
  end

  def self.create_new(qid, hid, summary, tag, topics)
    q = Question.find(qid)
    h = Homework.where(id: hid).first
    n = Note.create(subject: h.subject,
      type: q.type,
      content: q.content,
      items: q.items,
      answer: q.answer || -1,
      answer_content: q.answer_content,
      image_path: q.image_path,
      tag_set: h.tag_set,
      summary: summary,
      tag: tag)
    q.notes << n
    h.notes << n if h.present?
    topics.split(',').each do |e|
      next if e.blank?
      t = Topic.find_or_create(e, h.subject)
      t.notes << n if t.present?
    end
    n.update_attributes({question_str: n.content.join + (n.items || []).join,
      topic_str: n.topics.map { |e| e.name } .join(',') })
    n
  end

  def check_teacher(student)
    t = self.homework.user
    teachers = student.klasses.map { |e| e.teacher } .uniq
    if !teachers.include?(t)
      return t
    end
    nil
  end

  def item_len
    item_max_len = items.map { |e| e.item_length } .max
  end

  def set_answer
    if self.homework.answer_time_type == "no" || (self.homework.answer_time_type == "later" && Time.now.to_i < self.homework.answer_time)
      self.answer = -1
      self.answer_content = []
    end
  end

  def change_image_path
    if self.image_path.include?("portal.efei.org")
      new_image_path = self.image_path.gsub("portal.efei.org", "efei.org")
      self.update_attribute(:image_path, new_image_path)
    end
  end
end
