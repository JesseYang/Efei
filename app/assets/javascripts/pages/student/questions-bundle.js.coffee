#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
#= require jquery-ui.js
#= require jquery.tagsinput.js
$ ->
  $('.tags').tagsInput({
    'autocomplete_url': "http://b-fox.cn/topics?subject=" + window.subject,
    'defaultText': "",
    'width': '100%',
    'height': '20px'
  })
  $(".ui-autocomplete-input").attr("placeholder", "添加知识点")

  $(".summary").height(1).val(window.summary).autogrow()

  window.qid_to_note = []

  $("#check_questions").click ->
    window.location.href = "/student/questions/exercise?type=group&question_id=" + $(this).data("question-id")

  $("#append_note").click ->
    qid = $(this).data("question-id")
    parent_div = $(this).closest("div")
    note_type = parent_div.find(".note_type-select").val()
    topics = parent_div.find(".tags").val()
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

  $("#signin-btn").click ->
    email_mobile = $("#signin_user #email_mobile").val()
    password = $("#signin_user #password").val()
    $.postJSON(
      '/account/sessions/',
      {
        email_mobile: email_mobile,
        password: password
      },
      (retval) ->
        if retval.success
          append_question("sign_in")
        else
          $("#sign-notification").notification({content: retval.message})
    )


  $("#signup-btn").click ->
    email_mobile = $("#signup_user #email_mobile").val()
    password = $("#signup_user #password").val()
    name = $("#name").val()
    $.postJSON(
      '/account/registrations/',
      {
        email_mobile: email_mobile,
        password: password,
        name: name
      },
      (retval) ->
        console.log retval
        if retval.success
          append_question("sign_up")
        else
          $("#sign-notification").notification({content: retval.message})
    )
    return false

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
        window.location.href = "/student/notes/#{retval.note_id}?new_note=true"
    )
