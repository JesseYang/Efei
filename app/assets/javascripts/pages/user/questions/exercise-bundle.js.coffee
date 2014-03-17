#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
$ ->
  window.qid_to_note = []
  $(".question-items p").click ->
    $(this).find("input").prop("checked", true)
    $(this).closest('.question-items').find(".thick").removeClass('thick')
    $(this).closest('.question-items').find("p").removeClass('selected-p')
    $(this).find("span").addClass('thick')
    $(this).addClass('selected-p')

  $("#submit_answer").click ->
    # clear all the notifications
    $("#notification-div .warning").addClass("hide")
    $(".question-div").each ->
      $(this).find(".warning").addClass("hide")
      $(this).find(".correct").addClass("hide")
      $(this).find(".incorrect").addClass("hide")

    qid_ary = []
    answer_ary = []
    blank_answer = 0
    $(".question-div").each ->
      qid = $(this).data("question-id")
      qtype = $(this).data("question-type")
      if qtype == "choice"
        answer = $("input[name=" + qid + "-item-select]:checked").val()
        qid_ary.push qid
        answer_ary.push answer
      if answer == undefined && qtype == "choice"
        $(this).find(".warning").removeClass("hide")
        blank_answer += 1
    if $.inArray(undefined, answer_ary) != -1
      $("#notification-div .warning").html("有" + blank_answer + "道选择题未回答，请回答完毕后再提交")
      $("#notification-div .warning").removeClass("hide")
    else
      $.postJSON(
        '/user/questions/answer',
        {
          qid_ary: qid_ary,
          answer_ary: answer_ary
        },
        (retval) ->
          console.log retval
          # show the result for each questions
          correct_num = 0
          incorrect_num = 0
          for e in retval.result.detail
            if e.answer == e.user_answer
              # correct answer
              $("#" + e.qid + "-div").find(".correct").removeClass("hide")
              $("#" + e.qid + "-div").find(".incorrect").addClass("hide")
              correct_num += 1
            else
              # incorrect answer
              $("#" + e.qid + "-div").find(".correct-answer-span").html(d2c(e.answer))
              $("#" + e.qid + "-div").find(".correct").addClass("hide")
              $("#" + e.qid + "-div").find(".incorrect").removeClass("hide")
              incorrect_num += 1
            if e.note == true
              $("#" + e.qid + "-div").find(".append-note").addClass("hide")
            else
              $("#" + e.qid + "-div").find(".append-note").removeClass("hide")
          # show the answers
          $(".question-answer").removeClass("hide")
          # show the stats info
          if incorrect_num == 0
            # all right
            $(".correct-stats").html(correct_num + "道题正确")
            $(".incorrect-stats").html("")
          else if correct_num == 0
            # all wrong
            $(".incorrect-stats").html(incorrect_num + "道题错误")
            $(".correct-stats").html("")
          else
            # some right, some wrong
            $(".correct-stats").html(correct_num + "道题正确")
            $(".incorrect-stats").html(incorrect_num + "道题错误")
      )
    $("html, body").animate({ scrollTop: 0 }, "slow")
    false

  d2c = (d) ->
    switch d
      when 0 then return "A"
      when 1 then return "B"
      when 2 then return "C"
      when 3 then return "D"
      else return ""

  $(".append-note a").click ->
    qid = $(this).closest(".append-note").data("question-id")
    $this = $(this)
    $.postJSON(
      "/user/questions/#{qid}/append_note",
      { },
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.qid_to_note.push(qid)
          $('#sign').modal({
            show: 'false'
          });
        else
          $("#app-notification").notification({content: "已加入错题本"})
          $this.addClass("hide")
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
    # update the append_note link
    qid_ary = []
    $(".append-note").each ->
      qid_ary.push($(this).data("question-id"))
    $.getJSON(
      "/user/questions/check_note?qids=" + qid_ary.join(','),
      { },
      (retval) ->
        index = 0
        for result in retval.result
          if result == true
            $("#" + qid_ary[index] + "-div").find(".append-note").addClass("hide")
          else
            $("#" + qid_ary[index] + "-div").find(".append-note").removeClass("hide")
          index += 1
    # append the question
    $.postJSON(
      "/user/questions/#{qid}/append_note",
      { },
      (retval) ->
        $.refresh_navbar($("#sign_in_user #user_email").val())
        $("#" + qid + "-div").find(".append-note").addClass("hide")
    )
    # show the notification
    $("#app-notification").notification({content: content})
    )
