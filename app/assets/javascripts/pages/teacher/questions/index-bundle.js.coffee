#= require 'utility/ajax'
#= require "extensions/page_notification"
$ ->
  if window.scope == "personal"
    $("#personal").attr("checked", true)
  else if window.scope == "public"
    $("#public").attr("checked", true)
  else
    $("#personal").attr("checked", true)
    $("#public").attr("checked", true)

  $(".content-div").hover (->
    $(this).find(".compose-operation").removeClass "hide"
  ), (->
    $(this).find(".compose-operation").addClass "hide"
  )

  console.log window.compose_qid_str

  $(".content-div").each ->
    qid = $(this).attr("data-question-id")
    console.log qid
    if window.compose_qid_str.indexOf(qid) != -1
      $(this).find(".compose-status").removeClass("hide")

  $(".do-compose").click ->
    question_id = $(this).closest(".content-div").attr("data-question-id")
    that = this
    $.putJSON(
      '/teacher/composes/add',
      {
        question_id: question_id
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $(".compose-indicator .compose-question-number").text(retval.question_number)
          $(that).closest(".content-div").find(".compose-status").removeClass("hide")
    )

  $(".composed").click ->
    question_id = $(this).closest(".content-div").attr("data-question-id")
    that = this
    $.putJSON(
      '/teacher/composes/remove',
      {
        question_id: question_id
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $(".compose-indicator .compose-question-number").text(retval.question_number)
          $(that).closest(".content-div").find(".compose-status").addClass("hide")
          $(that).closest(".content-div").find(".compose-operation").addClass("hide")
    )

