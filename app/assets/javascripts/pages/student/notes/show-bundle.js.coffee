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
  $('#tags').importTags(window.topics);
  $("#tags_tag").attr("placeholder", "添加知识点")

  $(".summary").height(1).val(window.summary).autogrow()
  $(".summary").attr('val', window.summary)

  window.qid_to_note = []

  $("#toggle_answer").click ->
    a_div = $(this).closest(".question-content-div").find(".question-answer")
    if a_div.hasClass("hide")
      a_div.removeClass("hide")
      $(this).text("隐藏答案")
    else
      a_div.addClass("hide")
      $(this).text("显示答案")

  $("#update_note").click ->
    nid = $(this).data("note-id")
    parent_div = $(this).closest("div")
    note_type = parent_div.find("#note_type-select").val()
    topics = parent_div.find("#tags").val()
    summary = parent_div.find(".summary").val()
    $this = $(this)
    info = {note_type: note_type, topics: topics, summary: summary}
    $.putJSON(
      "/student/notes/#{nid}",
      info,
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.location.href = "/users/sign_in"
        else
          window.location.href = "/student/notes/#{retval.note_id}?flash=更新成功"
    )
    false
