#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
$ ->
  $("#check_questions").click ->
    $.get(
      '/user/questions/' + $(this).data("question-id") + '/similar',
      { },
      (retval) ->
        $(".page-operation-div").addClass("hide")
        $(".question-operation-div").removeClass("hide")
        $("#similar-questions-div").html(retval)
        $("#similar-questions-div").slideDown()
    )
    false

  $("#append_note").click ->
    $this = $(this)
    $.postJSON(
      '/user/questions/' + $(this).data("question-id") + '/append_note',
      { },
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          $('#sign').modal({
            show: 'false'
          });
        else
          $this.attr("disabled", true)
          $this.html("已加入错题本")
    )
    false

  $("form#sign_in_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      # hide the sign modal
      $('#sign').modal('hide')
      # append the question to the note
      $.postJSON(
        '/user/questions/' + $("#append_note").data("question-id") + '/append_note',
        { },
        (retval) ->
          $("#append_note").attr("disabled", true)
          $.refresh_navbar($("#sign_in_user #user_email").val())
      )
      # show the notification
      $("#app-notification").notification({content: "登录成功，已加入错题本"})
    else
      $("#sign-notification").notification({content: "邮箱或密码错误"})
      
  $("form#sign_up_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      # hide the sign modal
      $('#sign').modal('hide')
      # append the question to the note
      $.postJSON(
        '/user/questions/' + $("#append_note").data("question-id") + '/append_note',
        { },
        (retval) ->
          $("#append_note").attr("disabled", true)
          $.refresh_navbar($("#sign_up_user #user_email").val())
      )
      # show the notification
      $("#app-notification").notification({content: "注册成功，已加入错题本"})
    else
      $("#sign-notification").notification({content: "注册失败"})