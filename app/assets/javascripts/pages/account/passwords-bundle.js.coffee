#= require 'utility/ajax'
$(document).ready ->

  $("#password-form").submit ->
    email_mobile = $("#email_mobile").val()
    $.postJSON(
      '/account/passwords/',
      {
        email_mobile: email_mobile
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          window.location.href = "/account/sessions/new?flash=重置密码邮件已发送，请查收&email_mobile=#{email_mobile}"
    )
    return false
