#= require 'utility/ajax'
#= require "extensions/page_notification"
$(document).ready ->

  if window.role == "student"
    $("#teacher-regi").addClass("hide")
    $("#student-regi").removeClass("hide")

  $("#teacher-regi-form").submit ->
    email_mobile = $("#email_mobile").val()
    password = $("#password").val()
    name = $("#name").val()
    subject = $("#subject").val()
    invite_code = $("#invite_code").val()
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
          window.location.href = "/"
    )
    return false

  $("#student-regi-form").submit ->
    email_mobile = $("#email_mobile").val()
    password = $("#password").val()
    name = $("#name").val()
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
          window.location.href = "/"
    )
    return false

  $(".student-role").click ->
    $("#teacher-regi").addClass("hide")
    $("#student-regi").removeClass("hide")

  $(".teacher-role").click ->
    $("#teacher-regi").removeClass("hide")
    $("#student-regi").addClass("hide")
