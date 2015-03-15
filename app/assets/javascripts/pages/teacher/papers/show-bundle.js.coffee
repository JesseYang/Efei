#= require 'utility/ajax'
#= require "extensions/page_notification"

$ ->
  if window.show_compose == "true"
    $(".content-div").hover (->
      $(this).find(".compose-operation").removeClass "hide"
    ), (->
      $(this).find(".compose-operation").addClass "hide"
    )

  $(".content-div").hover (->
    $(this).find(".question-report-wrapper").removeClass "hide"
  ), (->
    $(this).find(".question-report-wrapper").addClass "hide"
  )

  $(".report-bug").click ->
    question_id = $(this).closest(".content-div").attr("data-question-id")
    $.postJSON(
      '/teacher/feedbacks',
      {
        question_id: question_id
      },
      (retval) ->
        if retval.success
          $.page_notification("谢谢！报错请求提交成功")
        else
          $.page_notification("服务器错误，请稍后再试")
    )

  $(".content-div").each ->
    qid = $(this).attr("data-question-id")
    if window.included_qid_str.indexOf(qid) != -1
      $(this).find(".include-status").removeClass("hide")
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

