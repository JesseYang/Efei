# encoding: utf-8
module ErrCode

  USER_NOT_EXIST = -1
  WRONG_PASSWORD = -2
  USER_EXIST = -3


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
    end
  end
end
