# encoding: utf-8
class WeixinBind
  include Mongoid::Document
  include Mongoid::Timestamps

  field :weixin_open_id, type: String
  # can be "coach" or "student"
  field :type, type: String
  field :nickname, type: String
  belongs_to :student, class_name: "User", inverse_of: :student_weixin_binds
  belongs_to :coach, class_name: "User", inverse_of: :coach_weixin_bind

  def self.find_student_by_open_id(open_id)
  	weixin_bind = WeixinBind.where(type: "student", weixin_open_id: open_id).first
  end

  def self.create_student_bind(student, info)
    wb = WeixinBind.create(weixin_open_id: info[:open_id], type: "student", nickname: info[:nickname])
    wb.student = student
    wb.save
  end
end
