#= require 'utility/ajax'
#= require "extensions/page_notification"
$(document).ready ->

  if window.role == "student"
    $("#teacher-login").addClass("hide")
    $("#student-login").removeClass("hide")

  $("#login-form").submit ->
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
          $.page_notification(retval.message)
        else
          $.page_notification("登录成功，正在跳转")
          window.location.href = "/"
    )
    return false

  $(".student-role").click ->
    $("#teacher-login").addClass("hide")
    $("#student-login").removeClass("hide")

  $(".teacher-role").click ->
    $("#teacher-login").removeClass("hide")
    $("#student-login").addClass("hide")
