# encoding: utf-8
class PlatformBind
  include Mongoid::Document
  include Mongoid::Timestamps

  field :weixin_open_id, type: String
  # can be "parent" or "teacher"
  field :type, type: String
  field :nickname, type: String
  belongs_to :parent, class_name: "User", inverse_of: :parent_weixin_binds
  belongs_to :teacher, class_name: "User", inverse_of: :teacher_weixin_bind

  def self.find_parent_by_open_id(open_id)
  	platform_bind = PlatformBind.where(type: "parent", weixin_open_id: open_id).first
  end

  def self.find_teacher_by_open_id(open_id)
    platform_bind = PlatformBind.where(type: "teacher", weixin_open_id: open_id).first
  end

  def self.create_parent_bind(parent, info)
    wb = PlatformBind.create(weixin_open_id: info[:open_id], type: "parent", nickname: info[:nickname])
    wb.parent = parent
    wb.save
  end

  def self.create_teacher_bind(teacher, info)
    wb = PlatformBind.create(weixin_open_id: info[:open_id], type: "teacher", nickname: info[:nickname])
    wb.teacher = teacher
    wb.save
  end
end
