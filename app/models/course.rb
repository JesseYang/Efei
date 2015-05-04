# encoding: utf-8
class Course
  include Mongoid::Document
  include Mongoid::Timestamps

  field :subject, type: Integer
  field :name, type: String
  field :start_at, type: Integer
  field :end_at, type: Integer
  field :grade, type: String
  field :desc, type: String
  field :suggestion, type: String
  field :textbook_url, type: String
  field :lesson_id_ary, type: Array

  field :ready, type: Boolean, default: false

  belongs_to :teacher, class_name: "User", inverse_of: :courses

  def info_for_tablet
    {
      server_id: self.id.to_s,
      teacer_id: self.teacher.id.to_s,
      subject: self.subject.to_i,
      name: self.name,
      start_at: self.start_at,
      end_at: self.end_at,
      grade: self.grade,
      desc: self.desc,
      suggestion: self.suggestion,
      textbook_url: self.textbook_url,
      update_at: self.updated_at.to_s
    }
    
  end

end
