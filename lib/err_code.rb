# encoding: utf-8
module ErrCode

  USER_NOT_EXIST = -1
  WRONG_PASSWORD = -2
  USER_EXIST = -3
  BLANK_EMAIL_MOBILE = -4
  WRONG_VERIFY_CODE = -5
  WRONG_TOKEN = -6
  EXPIRED = -7
  REQUIRE_SIGNIN = -8
  TEACHER_NOT_EXIST = -9
  QUESTION_NOT_EXIST = -10
  NOTE_NOT_EXIST = -11


  def self.ret_false(code)
    retval = { success: false }
    retval.merge({code: code, message: self.message(code)})
  end

  def self.message(code)
    case code
    when USER_NOT_EXIST
      "帐号不存在"
    when WRONG_PASSWORD
      "密码错误"
    when USER_EXIST
      "帐号已存在"
    when BLANK_EMAIL_MOBILE
      "帐号不能为空"
    when WRONG_VERIFY_CODE
      "验证码错误"
    when WRONG_TOKEN
      "token错误"
    when EXPIRED
      "token过期"
    when REQUIRE_SIGNIN
      "未登录"
    when TEACHER_NOT_EXIST
      "教师不存在"
    when QUESTION_NOT_EXIST
      "题目不存在"
    when NOTE_NOT_EXIST
      "题目不存在"
    end
  end
end
