#= require 'utility/ajax'
$ ->

  $(".change-password").click ->
    $("#changePasswordModal").modal("show")

  $("#changePasswordModal .ok").click ->
    password = $("#changePasswordModal #password").val()
    new_password = $("#changePasswordModal #new_password").val()
    new_password_confirmation = $("#changePasswordModal #new_password_confirmation").val()
    if new_password != new_password_confirmation
      $.page_notification "新密码与新密码确认不一致"
      return
    $.putJSON "/account/passwords/change_password",
    {
      password: password
      new_password: new_password
    },
    (data) ->
      if data.success
        $.page_notification "修改密码成功"
      else
        $.page_notification "操作失败，请刷新页面重试"
