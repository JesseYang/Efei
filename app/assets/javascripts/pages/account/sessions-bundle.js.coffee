#= require 'utility/ajax'
$(document).ready ->

  $("form").submit ->
    email_mobile = $("#email_mobile").val()
    password = $("#password").val()
    $.postJSON(
      '/account/sessions/',
      {
        email_mobile: email_mobile,
        password: password
      },
      (retval) ->
        if !retval.success
          $("#app-notification").notification({content: retval.message})
        else
          window.location.href = "/?notice=登录成功"
    )
    return false

