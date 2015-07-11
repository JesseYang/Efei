$ ->
  $("form").submit ->
    mobile = $(this).find("input#mobile").val()
    if mobile == ""
      $.page_notification "请输入您的手机号码"
      return false
    mobileReg = /^\d{11}$/
    if !mobileReg.test(mobile)
      $.page_notification "请输入正确的手机号码"
      return false
