#= require 'utility/ajax'
#= require "extensions/page_notification"
$(document).ready ->

  if window.role == "student"
    $("#teacher-login").addClass("hide")
    $("#student-login").removeClass("hide")

  $("#teacher-login-form").submit ->
    email_mobile = $("#teacher_email_mobile").val().trim()
    password = $("#teacher_password").val().trim()
    if password == ""
      $.page_notification("请输入密码")
      return false
    $.postJSON(
      '/account/sessions/',
      {
        email_mobile: email_mobile,
        password: password
        role: "teacher"
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $.page_notification("登录成功，正在跳转")
          window.location.href = "/redirect"
    )
    return false

  $("#student-login-form").submit ->
    email_mobile = $("#student_email_mobile").val().trim()
    password = $("#student_password").val().trim()
    if password == ""
      $.page_notification("请输入密码")
      return false
    $.postJSON(
      '/account/sessions/',
      {
        email_mobile: email_mobile,
        password: password
        role: "student"
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $.page_notification("登录成功，正在跳转")
          window.location.href = "/redirect"
    )
    return false

  $(".student-role").click ->
    $("#teacher-login").addClass("hide")
    $("#student-login").removeClass("hide")

  $(".teacher-role").click ->
    $("#teacher-login").removeClass("hide")
    $("#student-login").addClass("hide")
