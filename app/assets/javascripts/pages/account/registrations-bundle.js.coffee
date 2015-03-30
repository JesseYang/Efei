#= require 'utility/ajax'
#= require "extensions/page_notification"
$(document).ready ->

  if window.role == "student"
    $("#teacher-regi").addClass("hide")
    $("#student-regi").removeClass("hide")

  $("#teacher-regi-form").submit ->
    email_mobile = $("#teacher_email_mobile").val().trim()
    verify = !!email_mobile.match(/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-])+/)
    if !verify
      $.page_notification("请输入正确的邮箱地址")
      return false
    password = $("#teacher_password").val().trim()
    if password.length < 6
      $.page_notification("请输入至少6位密码")
    name = $("#teacher_name").val().trim()
    if name == ""
      $.page_notification("请输入真实姓名")
    subject = $("#teacher_subject").val()
    invite_code = $("#teacher_invite_code").val().trim()
    $.postJSON(
      '/account/registrations/',
      {
        email_mobile: email_mobile
        password: password
        name: name
        role: "teacher"
        subject: subject
        invite_code: invite_code
      },
      (retval) ->
        console.log retval
        if !retval.success
          $.page_notification(retval.message)
        else
          $.page_notification("注册成功，正在跳转")
          window.location.href = "/redirect"
    )
    return false

  $("#student-regi-form").submit ->
    email_mobile = $("#student_email_mobile").val().trim()
    verify = !!email_mobile.match(/^1[0-9]{10}$/)
    if !verify
      $.page_notification("请输入正确的11位手机号")
      return false
    password = $("#student_password").val().trim()
    if password.length < 6
      $.page_notification("请输入至少6位密码")
    name = $("#student_name").val().trim()
    if name == ""
      $.page_notification("请输入真实姓名")
    $.postJSON(
      '/account/registrations/',
      {
        email_mobile: email_mobile
        password: password
        name: name
        role: "student"
      },
      (retval) ->
        console.log retval
        if !retval.success
          $.page_notification(retval.message)
        else
          $.page_notification("注册成功，正在跳转")
          window.location.href = "/redirect"
    )
    return false

  $(".student-role").click ->
    $("#teacher-regi").addClass("hide")
    $("#student-regi").removeClass("hide")

  $(".teacher-role").click ->
    $("#teacher-regi").removeClass("hide")
    $("#student-regi").addClass("hide")
