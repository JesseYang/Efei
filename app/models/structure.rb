# encoding: utf-8
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :subject, type: Integer
  # edition, book, chapter, section, subsection, point
  field :type, type: String
  field :children_id, type: Array, default: []

  has_and_belongs_to_many :children, class_name: "Structure", inverse_of: :parents
  has_and_belongs_to_many :parents, class_name: "Structure", inverse_of: :children

  def structure_tree(cur_chp = -1, cur_sec = -1, cur_sub = -1)
    tree = [ ]
    name = self.name
    case self.type
    when "chapter"
      name = "第#{cur_chp}章 #{self.name}"
    when "section"
      name = "#{cur_chp}.#{cur_sec} #{self.name}"
    when "subsection"
      name = "#{cur_chp}.#{cur_sec}.#{cur_sub} #{self.name}"
    end
    tree = {
      id: self.id.to_s,
      name: name,
      children: []
    }
    collection = self.children.asc(:created_at)
    collection.each_with_index do |n, i|
      cur_chp = i + 1 if n.type == "chapter"
      cur_sec = i + 1 if n.type == "section"
      cur_sub = i + 1 if n.type == "subsection"
      tree[:children] << n.structure_tree(cur_chp, cur_sec, cur_sub)
    end
    tree
  end

  def self.editions
    self.where(type: "edition").asc(:created_at)
  end

  def books
    self.children.asc(:created_at)
    
  end

  def self.default_edition(edition_id)
    e = Structure.where(type: "edition", id: edition_id).first
    if e.present?
      e
    else
      self.where(type: "edition", name: "人教A版").first
    end
  end

  def default_book(book_id)
    b = self.children.where(type: "book", id: book_id)
    if b.present?
      b
    else
      self.children.asc(:created_at).first
    end
  end

  def self.import
    cur_edition = nil
    cur_book = nil
    cur_chapter = nil
    cur_section = nil
    f = File.open('public/structure')
    ary = f.read.split("\n")
    ary.each do |ele|
      n = ele.index /\S/
      case n
      when 0
        s = Structure.create(name: ele.strip, subject: 2, type: "edition")
        cur_edition = s
      when 1
        s = Structure.create(name: ele.strip, subject: 2, type: "book")
        cur_book = s
        cur_edition.children << s
        cur_edition.children_id << s.id.to_s
        cur_edition.save
      when 2
        s = Structure.create(name: ele.strip, subject: 2, type: "chapter")
        cur_chapter = s
        cur_book.children << s
        cur_book.children_id << s.id.to_s
        cur_book.save
      when 3
        s = Structure.create(name: ele.strip, subject: 2, type: "section")
        cur_section = s
        cur_chapter.children << s
        cur_chapter.children_id << s.id.to_s
        cur_chapter.save
      when 4
        s = Structure.create(name: ele.strip, subject: 2, type: "subsection")
        cur_section.children << s
        cur_section.children_id << s.id.to_s
        cur_section.save
      end
    end
  end

  def print(indent)
    puts indent + self.name
    self.children_id.each do |eid|
      e = Structure.find(eid)
      e.print(indent + " ")
    end
  end

  def print_end
    puts self.name if self.children.blank?
    self.children_id.each do |eid|
      e = Structure.find(eid)
      e.print_end
    end
  end
end
