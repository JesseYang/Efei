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
