# encoding: utf-8
module UserComponents::Teacher
  extend ActiveSupport::Concern

  included do
    field :teacher, type: Boolean, default: false
    field :subject, type: Integer
    field :teacher_desc, type: String
    field :tag_sets, type: Array, default: []
    field :admin, type: Boolean, default: false

    has_many :homeworks, class_name: "Homework", inverse_of: :user
    belongs_to :school, class_name: "School", inverse_of: :teachers
    has_many :classes, class_name: "Klass", inverse_of: :teacher
    has_many :folders, class_name: "Folder", inverse_of: :user
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
    new_tag_set = tag_set_str.split(/,|，/).map { |e| e.strip } .uniq
    self.tag_sets.each do |tag_set|
      if tag_set.sort == new_tag_set.sort
        return ErrCode.ret_false(ErrCode::TAG_EXIST)
      end
    end
    self.tag_sets << new_tag_set
    self.save
    return { success: true, tag_set: new_tag_set }
  end

  def update_tag_set(index, tag_set_str)
    new_tag_set = tag_set_str.split(/,|，/).map { |e| e.strip } .uniq
    self.tag_sets.each do |tag_set|
      if tag_set.sort == new_tag_set.sort
        return ErrCode.ret_false(ErrCode::TAG_EXIST)
      end
    end
    self.tag_sets[index] = new_tag_set
    self.save
    return { success: true, tag_set: new_tag_set }
  end

  def remove_tag_set(index, tag_set_str)
    self.tag_sets.delete(tag_set_str)
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