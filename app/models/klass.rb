# encoding: utf-8
class Klass
  include Mongoid::Document
  include Mongoid::Timestamps

  field :default, type: Boolean, default: false
  field :name, type: String
  field :desc, type: String, default: ""
  field :visible, type: Boolean, default: true

  belongs_to :school, class_name: "School", inverse_of: :classes
  has_and_belongs_to_many :teachers, class_name: "User", inverse_of: :classes
  has_and_belongs_to_many :students, class_name: "User", inverse_of: :klasses

  def rename(name)
  	self.update_attribute :name, name
  end

  def clear_students
    self.students.clear and return if self.default
    other_classes = self.teacher.classes.where(:id.ne => self.id)
    the_other_class = self.teacher.classes.where(default: true).first
    other_students = other_classes.map { |e| e.students } .flatten .uniq
    self.students.each do |s|
      the_other_class.students << s if !other_students.include?(s)
    end
    self.students.clear
  end
end
