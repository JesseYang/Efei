# encoding: utf-8
module UserComponents::Teacher
  extend ActiveSupport::Concern

  included do
    field :teacher, type: Boolean, default: false
    field :subject, type: Integer
    field :teacher_desc, type: String
    field :admin, type: Boolean, default: false

    has_many :homeworks, class_name: "Homework", inverse_of: :user
    has_many :slides, class_name: "Homework", inverse_of: :user
    belongs_to :school, class_name: "School", inverse_of: :teachers
    has_many :classes, class_name: "Klass", inverse_of: :teacher
    has_many :folders, class_name: "Folder", inverse_of: :user
    has_many :tag_sets, class_name: "TagSet", inverse_of: :teacher
  end

  def ensure_default_class
    if !self.classes.where(default: true).first
      self.classes.create(default: true, name: "其他")
    end
  end

  def add_to_class(class_id, student)
    return if self.has_student?(student)
    klass = self.classes.where(id: class_id).first || self.classes.where(default: true).first || self.classes.create(default: true, name: "其他")
    klass.students << student
    return { success: true }
  end

  def remove_student(student)
    self.classes.each do |c|
      c.students.delete(student)
    end
  end

  def has_student?(student)
    all_students_id = self.classes.map { |e| e.students.map { |stu| stu.id.to_s } } .flatten
    all_students_id.include?(student.id.to_s)
  end

  def has_teacher?(teacher)
    teacher.has_student?(self)
  end

  def create_tag_set(tag_set_str)
    tag_set_ary = tag_set_str.split(/,|，/).map { |e| e.strip } .uniq
    tag_set = self.tag_sets.create(subject: self.subject, tags: tag_set_ary)
    return { success: true, tag_set: tag_set }
  end

  def update_tag_set(id, tag_set_str)
    tag_set_ary = tag_set_str.split(/,|，/).map { |e| e.strip } .uniq
    tag_set = self.tag_sets.where(id: id).first
    if tag_set.blank?
      return ErrCode.ret_false(ErrCode::TAG_EXIST)
    else
      tag_set.update_attribute(:tags, tag_set_ary)
      return { success: true, tag_set: tag_set }
    end
  end

  def remove_tag_set(id)
    tag_set = self.tag_sets.where(id: id).first
    self.tag_sets.delete(tag_set) if tag_set.present?
    { success: true }
  end

  def root_folder
    f = self.folders.where(is_root: true).first
    f.nil? ? self.folders.create(is_root: true) : f
  end

  def create_class(name)
    self.classes.create(name: name)
  end
end