#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
$ ->
  window.qid_to_note = []

  $("#check_questions").click ->
    window.location.href = "/user/questions/exercise?type=group&question_id=" + $(this).data("question-id")

  $("#append_note").click ->
    qid = $(this).data("question-id")
    $this = $(this)
    $.postJSON(
      "/user/questions/#{qid}/append_note",
      { },
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.qid_to_note.push(qid)
          window.ele_to_disable = [$this, $("#current-question-div .note-link")]
          window.text_to_set = "已加入错题本"
          $('#sign').modal({
            show: 'false'
          });
        else
          $("#app-notification").notification({content: "已加入错题本"})
          for ele in [$this, $("#current-question-div .note-link")]
            ele.attr("disabled", true)
            ele.html("已加入错题本")
    )
    false

  $("form#sign_in_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      append_question()
    else
      $("#sign-notification").notification({content: "邮箱或密码错误"})
      
  $("form#sign_up_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      append_question()
    else
      $("#sign-notification").notification({content: "注册失败"})

  append_question = ->
    # hide the sign modal
    $('#sign').modal('hide')
    # get the question to handle
    if window.qid_to_note.length == 1
      qid = window.qid_to_note.pop()
      action = "append_note"
      content = "登录成功，已加入错题本"
    else
      return
    # append the question
    $.postJSON(
      "/user/questions/#{qid}/#{action}",
      { },
      (retval) ->
        for ele in window.ele_to_disable
          ele.attr("disabled", true)
          ele.html(window.text_to_set)
        $.refresh_navbar($("#sign_in_user #user_email").val())
    )
    # show the notification
    $("#app-notification").notification({content: content})
