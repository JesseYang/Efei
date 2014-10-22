#= require 'utility/ajax'
$(document).ready ->

  $("form").submit ->
    email_mobile = $("#email_mobile").val()
    password = $("#password").val()
    $.postJSON(
      '/account/registrations/',
      {
        email_mobile: email_mobile,
        password: password
      },
      (retval) ->
        console.log retval
        if !retval.success
          $("#app-notification").notification({content: retval.message})
        else
          window.location.href = "/?notice=注册成功"
    )
    return false

