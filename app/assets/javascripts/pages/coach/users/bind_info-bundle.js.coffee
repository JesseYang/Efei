#= require 'utility/ajax'
$ ->
  $(".password-form").submit ->
    cur_password = $("#cur_password").val()
    new_password = $("#new_password").val()
    new_password_confirm = $("#new_password_confirm").val()
    if new_password != new_password_confirm
      $.page_notification "新密码与确认不一致"
      return false
    $.postJSON(
      '/coach/users/change_password',
      {
        cur_password: cur_password
        new_password: new_password
      },
      (retval) ->
        if retval.success
          $.page_notification("密码修改成功")
        else
          $.page_notification(retval.message)
    )
    return false
