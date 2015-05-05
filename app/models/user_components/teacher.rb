# encoding: utf-8
module UserComponents::Teacher
  extend ActiveSupport::Concern

  included do
    field :teacher, type: Boolean, default: false
    field :subject, type: Integer
    field :teacher_desc, type: String
    field :admin, type: Boolean, default: false

    # for table app
    field :avatar_url, type: String, default: ""
    field :desc, type: String, default: ""
    has_many :courses, class_name: "Course", inverse_of: :teacher

    has_many :nodes, class_name: "Node", inverse_of: :user
    has_one :compose, class_name: "Compose", inverse_of: :user
    # has_many :homeworks, class_name: "Homework", inverse_of: :user
    # has_many :slides, class_name: "Homework", inverse_of: :user
    # has_many :folders, class_name: "Folder", inverse_of: :user
    belongs_to :school, class_name: "School", inverse_of: :teachers
    has_many :classes, class_name: "Klass", inverse_of: :teacher
    has_many :tag_sets, class_name: "TagSet", inverse_of: :teacher
  end

  def folders
    self.nodes.where(_type: Folder)
  end

  def homeworks
    self.nodes.where(_type: Homework)
  end

  def slides
    self.nodes.where(_type: Slide)
  end

  def ensure_default_class
    if !self.classes.where(default: true).first
      self.classes.create(default: true, name: "其他")
    end
  end

  def ensure_compose(homework_id = nil)
    if self.compose.blank?
      self.compose = Compose.create(homework_id: homework_id)
    end
    self.compose
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
    f.nil? ? self.nodes.create({is_root: true, name: "我的文件夹"}, Folder) : f
  end

  def create_class(name)
    self.classes.create(name: name)
  end

  def create_question_feedback(qid)
    q = Question.find(qid)
    f = Feedback.create(user_id: self.id.to_s, question_id: q.id.to_s)
  end

  def info_for_tablet
    {
      server_id: self.id.to_s,
      avatar_url: self.avatar_url.to_s,
      name: self.name,
      desc: self.desc,
      update_at: self.updated_at.to_s
    }
  end
end