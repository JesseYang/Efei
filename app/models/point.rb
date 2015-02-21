# encoding: utf-8
class Point
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :subject, type: Integer
  # 0, 1, 2
  field :level, type: Integer
  field :children_id, type: Array, default: []

  has_and_belongs_to_many :children, class_name: "Point", inverse_of: :parents
  has_and_belongs_to_many :parents, class_name: "Point", inverse_of: :children

  has_and_belongs_to_many :questions, class_name: "Question", inverse_of: :points

  def root_point
    self.parents.present? ? self.parents[0].root_point : self
  end

  def point_tree
    tree = [ ]
    tree = {
      id: self.id.to_s,
      name: self.name,
      children: []
    }
    collection = self.children.asc(:created_at)
    collection.each do |n|
      tree[:children] << n.point_tree
    end
    tree
  end

  def push_question(q)
    self.parents.each do |p|
      p.push_question(q)
    end
    self.questions << q
  end

  def self.import
    Point.destroy_all
    cur_1 = nil
    cur_2 = nil
    f = File.open('public/point')
    ary = f.read.split("\n")
    ary.each do |ele|
      n = ele.index /\S/
      case n
      when 0
        s = Point.create(name: ele.strip, subject: 2, level: 0)
        cur_1 = s
      when 2
        s = Point.create(name: ele.strip, subject: 2, level: 1)
        cur_2 = s
        cur_1.children << s
        cur_1.children_id << s.id.to_s
        cur_1.save
      when 4
        s = Point.create(name: ele.strip, subject: 2, level: 2)
        cur_2.children << s
        cur_2.children_id << s.id.to_s
        cur_2.save
      end
    end
  end

  def print(indent)
    puts indent + self.name
    self.children_id.each do |eid|
      e = Point.find(eid)
      e.print(indent + " ")
    end
  end

  def self.points(level)
    Point.where(level: level).asc(:created_at)
  end
end
