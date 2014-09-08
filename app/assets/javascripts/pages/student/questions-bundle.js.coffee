#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
#= require jquery-ui.js
#= require jquery.tagsinput.js
$ ->
  $('#tags').tagsInput({
    'autocomplete_url': "http://b-fox.cn/topics?subject=" + window.subject,
    'defaultText': "",
    'width': '100%',
    'height': '20px'
  })
  $("#tags_tag").attr("placeholder", "添加知识点")

  $(".summary").height(1).val(window.summary).autogrow()

  window.qid_to_note = []

  $("#toggle_answer").click ->
    a_div = $(this).closest(".question-content-div").find(".question-answer")
    if a_div.hasClass("hide")
      a_div.removeClass("hide")
      $(this).text("隐藏答案")
    else
      a_div.addClass("hide")
      $(this).text("显示答案")

  $("#check_questions").click ->
    window.location.href = "/student/questions/exercise?type=group&question_id=" + $(this).data("question-id")

  $("#append_note").click ->
    qid = $(this).data("question-id")
    parent_div = $(this).closest("div")
    note_type = parent_div.find("#note_type-select").val()
    topics = parent_div.find("#tags").val()
    summary = parent_div.find(".summary").val()
    $this = $(this)
    info = {note_type: note_type, topics: topics, summary: summary}
    $.postJSON(
      "/student/questions/#{qid}/append_note",
      info,
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.qid_to_note.push([qid, info])
          $('#sign').modal({
            show: 'false'
          });
        else
          window.location.href = "/student/notes/#{retval.note_id}"
    )
    false

  $("form#sign_in_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      append_question("sign_in")
    else
      $("#sign-notification").notification({content: "邮箱或密码错误"})
      
  $("form#sign_up_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      append_question("sign_up")
    else
      $("#sign-notification").notification({content: "注册失败"})

  append_question = (type) ->
    # hide the sign modal
    $('#sign').modal('hide')
    # get the question to handle
    if window.qid_to_note.length == 1
      [qid, info] = window.qid_to_note.pop()
      action = "append_note"
    else
      return
    # append the question
    $.postJSON(
      "/student/questions/#{qid}/#{action}",
      info,
      (retval) ->
        window.location.href = "/student/notes/#{retval.note_id}"
    )
