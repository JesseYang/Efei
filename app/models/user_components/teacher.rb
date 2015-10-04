# encoding: utf-8
module UserComponents::Teacher
  extend ActiveSupport::Concern

  included do
    field :teacher, type: Boolean, default: false
    field :subject, type: Integer
    field :teacher_desc, type: String

    # for tablet app
    field :avatar_url, type: String, default: ""
    field :desc, type: String, default: ""
    field :tablet_teacher, type: Boolean, default: false
    has_many :courses, class_name: "Course", inverse_of: :teacher

    has_many :exams, class_name: "Exam", inverse_of: :teacher

    has_many :nodes, class_name: "Node", inverse_of: :user
    has_one :compose, class_name: "Compose", inverse_of: :user
    belongs_to :school, class_name: "School", inverse_of: :teachers
    has_and_belongs_to_many :classes, class_name: "Klass", inverse_of: :teachers
    has_many :tag_sets, class_name: "TagSet", inverse_of: :teacher
  end

  module ClassMethods
    def tablet_teachers
      hash = { "请选择" => -1 }
      User.where(tablet_teacher: true).each do |t|
        hash[t.name] = t.id.to_s
      end
      hash
    end
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

  def ensure_compose(homework_id = nil)
    if self.compose.blank?
      self.compose = Compose.create(homework_id: homework_id)
    end
    self.compose
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

  def set_classes(class_id_ary)
    remove_ary = [ ]
    self.classes.each do |c|
      if !class_id_ary.include?(c.id.to_s)
        remove_ary << c
        class_id_ary.delete(c.id.to_s)
      end
    end
    remove_ary.each do |c|
      self.classes.delete(c)
    end
    class_id_ary.each do |cid|
      c = Klass.where(id: cid).first
      self.classes << c
    end
  end
end