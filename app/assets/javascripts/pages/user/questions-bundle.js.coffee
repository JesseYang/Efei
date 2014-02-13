#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
$ ->
  window.qid_to_note = []
  window.qid_to_print = []

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

  $(document).on 'click', '.question-operation-div .paper-link', ->
    qid = $(this).data("question-id")
    $this = $(this)
    $.postJSON(
      "/user/questions/#{qid}/append_paper",
      { },
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.qid_to_print.push(qid)
          window.ele_to_disable = [$this]
          window.text_to_set = "已加入试卷"
          $('#sign').modal({
            show: 'false'
          });
        else
          $this.attr("disabled", true)
          $("#app-notification").notification({content: "已加入打印纸"})
          $this.html("已加入试卷")
    )
    false

  $(document).on 'click', '.question-operation-div .note-link', ->
    qid = $(this).data("question-id")
    $this = $(this)
    $.postJSON(
      "/user/questions/#{qid}/append_note",
      { },
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.qid_to_note.push(qid)
          window.ele_to_disable = [$this]
          window.text_to_set = "已加入错题本"
          $('#sign').modal({
            show: 'false'
          });
        else
          $this.attr("disabled", true)
          $("#app-notification").notification({content: "已加入错题本"})
          $this.html("已加入错题本")
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
    else if window.qid_to_print.length == 1
      qid = window.qid_to_print.pop()
      action = "append_print"
      content = "登录成功，已加入试卷"
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
