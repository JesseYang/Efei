# encoding: utf-8
class Structure
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :subject, type: Integer
  # edition, book, chapter, section, subsection, point
  field :type, type: String

  has_and_belongs_to_many :children, class_name: "Structure", inverse_of: :parents
  has_and_belongs_to_many :parents, class_name: "Structure", inverse_of: :children

  def self.import_edition
    self.destroy_all

    # editions
    editions = []
    editions << self.create(name: "人教A版", subject: 2, type: "edition")
    editions << self.create(name: "人教B版", subject: 2, type: "edition")
    editions << self.create(name: "北师大", subject: 2, type: "edition")
    editions << self.create(name: "苏教版", subject: 2, type: "edition")
    editions << self.create(name: "湘教版", subject: 2, type: "edition")

    # text books
    t = editions[0].children.create(name: "必修1", subject: 2, type: "book")
    t.children.create(name: "集合与函数概念", subject: 2, type: "chapter")
    editions[0].children.create(name: "必修2", subject: 2, type: "book")
    editions[0].children.create(name: "必修3", subject: 2, type: "book")
    editions[0].children.create(name: "必修4", subject: 2, type: "book")
    editions[0].children.create(name: "必修5", subject: 2, type: "book")
    editions[0].children.create(name: "选修1-1", subject: 2, type: "book")
    editions[0].children.create(name: "选修1-2", subject: 2, type: "book")
    editions[0].children.create(name: "选修2-1", subject: 2, type: "book")
    editions[0].children.create(name: "选修2-2", subject: 2, type: "book")
    editions[0].children.create(name: "选修2-3", subject: 2, type: "book")
    editions[0].children.create(name: "选修4-1", subject: 2, type: "book")
    editions[0].children.create(name: "选修4-4", subject: 2, type: "book")
  end
end
