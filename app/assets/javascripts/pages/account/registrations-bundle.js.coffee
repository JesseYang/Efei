#= require 'utility/ajax'
#= require "extensions/page_notification"
$(document).ready ->

  $("#registration-form").submit ->
    email_mobile = $("#email_mobile").val()
    password = $("#password").val()
    name = $("#name").val()
    role = $("#role").val()
    subject = $("#subject").val()
    $.postJSON(
      '/account/registrations/',
      {
        email_mobile: email_mobile
        password: password
        name: name
        role: role
        subject: subject
      },
      (retval) ->
        console.log retval
        if !retval.success
          $.page_notification(retval.message)
        else
          $.page_notification("注册成功，正在跳转")
          window.location.href = "/"
    )
    return false

