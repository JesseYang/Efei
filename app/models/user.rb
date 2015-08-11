# encoding: utf-8
require 'open-uri'
require 'err_code'
require 'string'
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include UserComponents::Student
  include UserComponents::Teacher
  include UserComponents::Coach
  include UserComponents::SchoolAdmin

  # user basic info
  field :email, type: String, default: ""
  field :mobile, type: String, default: ""
  field :name, type: String, default: ""
  field :password, type: String, default: ""

  # for restting email
  field :new_email, type: String, default: ""
  field :reset_password_verify_code, type: String, default: ""
  field :reset_password_token, type: String, default: ""

  # for restting mobile
  field :new_mobile, type: String, default: ""
  field :reset_mobile_verify_code, type: String, default: ""
  field :reset_mobile_expire_time, type: Integer

  # for registration invitation
  field :invite_code, type: String


  field :admin, type: Boolean, default: false
  field :super_admin, type: Boolean, default: false
  field :permission, type: Integer, default: 0

  has_many :feedbacks

  include HTTParty
  base_uri Rails.application.config.word_host
  format  :json

  def self.find_by_auth_key(auth_key)
    info = Encryption.decrypt_auth_key(auth_key)
    user_id = info.split(',')[0]
    User.where(id: user_id).first
  end

  def self.find_by_email_mobile(email_mobile)
    return nil if email_mobile.blank?
    if email_mobile.is_mobile?
      u = User.where(mobile: email_mobile).first
    else
      u = User.where(email: email_mobile).first
    end
    u
  end

  def generate_auth_key
    info = "#{self.id.to_s},#{Time.now.to_i}"
    Encryption.encrypt_auth_key(info)
  end

  def self.create_new_user(invite_code, email_mobile, password, name, school_name, role="student", subject=2, tablet=false)
    role ||= "student"
    if role == "teacher"
      i = InviteCode.where(code: invite_code, used: false).first
      return ErrCode.ret_false(ErrCode::WRONG_INVITE_CODE) if i.blank?
    end
    return ErrCode.ret_false(ErrCode::BLANK_EMAIL_MOBILE) if email_mobile.blank?
    u = User.where(email: email_mobile).first || User.where(mobile: email_mobile).first
    return ErrCode.ret_false(ErrCode::USER_EXIST) if u.present?
    if email_mobile.is_mobile?
      u = User.create(invite_code: invite_code, mobile: email_mobile, password: Encryption.encrypt_password(password), name: name)
    else
      u = User.create(invite_code: invite_code, email: email_mobile, password: Encryption.encrypt_password(password), name: name)
    end
    if role == "teacher"
      u.update_attribute(:teacher, true)
      u.update_attribute(:subject, subject.to_i)
      if school_name.present?
        s = School.where(name: school_name).first || School.create(name: school_name)
        u.update_attribute(:school_id, s.id.to_s)
      end
      u.ensure_default_class
      i.update_attribute(:used, true)
    elsif tablet
      u.update_attribute(:tablet, true)
    end
    return { success: true, auth_key: u.generate_auth_key }
  end

  def self.login(email_mobile, password)
    return ErrCode.ret_false(ErrCode::BLANK_EMAIL_MOBILE) if email_mobile.blank?
    u = User.where(email: email_mobile).first || User.where(mobile: email_mobile).first
    return ErrCode.ret_false(ErrCode::USER_NOT_EXIST) if u.blank?
    return ErrCode.ret_false(ErrCode::WRONG_PASSWORD) if u.password != Encryption.encrypt_password(password)
    return { success: true, auth_key: u.generate_auth_key }
  end

  def self.tablet_login(email_mobile, password)
    return ErrCode.ret_false(ErrCode::BLANK_EMAIL_MOBILE) if email_mobile.blank?
    u = User.where(email: email_mobile, tablet: true).first || User.where(mobile: email_mobile, tablet: true).first
    return ErrCode.ret_false(ErrCode::USER_NOT_EXIST) if u.blank?
    return ErrCode.ret_false(ErrCode::WRONG_PASSWORD) if u.password != Encryption.encrypt_password(password)
    return {
      success: true,
      auth_key: u.generate_auth_key,
      admin: u.admin,
      course_id_str: u.student_course_id_str,
      lesson_id_str: u.completed_lesson_id_str,
      status: u.studies,
      student_server_id: u.id.to_s
    }
  end

  def send_reset_password_code
    self.reset_password_verify_code = "111111"
    self.reset_password_token = self.generate_auth_key
    self.save
    # TODO: send the sms
  end

  def self.app_reset_password(reset_password_token, password)
    info = Encryption.decrypt_auth_key(reset_password_token)
    uid, time = *info.split(",")
    u = User.where(id: uid).first
    return ErrCode.ret_false(ErrCode::WRONG_TOKEN) if u.nil?
    return ErrCode.ret_false(ErrCode::EXPIRED) if Time.now.to_i - time.to_i > Rails.application.config.expire_time
    u.update_attributes(password: Encryption.encrypt_password(password))
    return { success: true }
  end

  def self.reset_password(key, password)
    password_info = Encryption.decrypt_activate_key(CGI::unescape(key))
    email = password_info.split(',')[0]
    u = User.where(email: email).first
    u.password = Encryption.encrypt_password(password)
    u.save
    return { success: true, auth_key: u.generate_auth_key }
  end

  def email_for_short
    if self.email.length < 20
      self.email
    else
      self.email[0..19] + "..."
    end
  end

  def rename(name)
    self.update_attributes(name: name)
    return
  end

  def change_password(password, new_password)
    if self.password != Encryption.encrypt_password(password)
      return ErrCode.ret_false(ErrCode::WRONG_PASSWORD)
    end
    self.update_attributes(password: Encryption.encrypt_password(new_password))
    return
  end

  def change_email(email)
    if User.where(email: email).first.present?
      return ErrCode.ret_false(ErrCode::USER_EXIST)
    end
    self.update_attributes(new_email: email)
    # TODO: send an email to the email address, with a link and a key as the link parameter. The key should contains the email address, the user id, and the time information
    ResetEmailWorker.perform_async(self.id.to_s, email)
    return
  end

  def self.verify_email(key)
    info = Encryption.decrypt_reset_email_key(key)
    uid, email, time = *info.split(",")
    u = User.where(id: uid).first
    return ErrCode.ret_false(ErrCode::WRONG_TOKEN) if u.blank?
    return ErrCode.ret_false(ErrCode::WRONG_TOKEN) if u.new_email != email
    return ErrCode.ret_false(ErrCode::EXPIRED) if Time.now.to_i - time.to_i > Rails.application.config.email_expire_time
    u.email = email
    u.new_email = nil
    u.save
    return { success: true, email: email }
  end

  def change_mobile(mobile)
    if User.where(mobile: mobile).first.present?
      return ErrCode.ret_false(ErrCode::USER_EXIST)
    end
    self.reset_mobile_verify_code = "111111"
    self.new_mobile = mobile
    self.reset_mobile_expire_time = Time.now.to_i + Rails.application.config.expire_time
    self.save
    # TODO: send the sms
    return
  end

  def verify_mobile(code)
    if self.reset_mobile_verify_code != code
      return ErrCode.ret_false(ErrCode::WRONG_VERIFY_CODE)
    end
    self.mobile = new_mobile
    self.reset_mobile_verify_code = ""
    self.new_mobile = ""
    self.reset_mobile_expire_time = nil
    self.save
    return
  end

  def create_feedback(content)
    f = Feedback.create(content: content, user_id: self.id.to_s)
  end

  def default_admin_path
    if self.admin != true || self.permission == 0
      return ""
    elsif self.super_admin
      "/admin/supers"
    elsif self.permission & 1 == 1
      "/admin/teachers"
    elsif self.permission & 2 == 2
      "/admin/courses"
    elsif self.permission & 4 == 4
      "/admin/weixin_news"
    elsif self.permission & 8 == 8
      "/admin/coaches"
    elsif self.permission & 16 == 16
      "/admin/local_courses"
    elsif self.permission & 32 == 32
      "/admin/students"
    end
  end
end
