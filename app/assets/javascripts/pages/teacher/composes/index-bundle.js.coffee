#= require 'utility/ajax'
#= require "extensions/page_notification"
$ ->

  $(".content-div").hover (->
    $(this).find(".question-operation-div").removeClass "hide"
  ), (->
    $(this).find(".question-operation-div").addClass "hide"
  )

  $(".remove-compose-question").click ->
    question_id = $(this).closest(".btn-group").attr("data-qid")
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
          $(that).closest(".content-div").slideUp()
          $(".compose-indicator .compose-question-number").text(retval.question_number)
    )

  $(".clear-link").click ->
    $.putJSON "/teacher/composes/clear", {}, (data) ->
      if data.success
        $.page_notification "清空完毕"
        $(".content-div").remove()
        $(".compose-indicator .compose-question-number").text(0)
      else
        $.page_notification "操作失败，请刷新页面重试"

  $(".cancel-link").click ->
    $.deleteJSON "/teacher/composes/cancel", {}, (data) ->
      if data.success
        $.page_notification "已经放弃，正在跳转"
        window.location.href = "/teacher/nodes"
      else
        $.page_notification "操作失败，请刷新页面重试"

  $(".confirm-link").click ->
    $.putJSON "/teacher/composes/confirm", {}, (data) ->
      if data.success
        $.page_notification "已经确认，正在跳转"
        window.location.href = "/teacher/homeworks/#{window.homework_id}"
      else
        $.page_notification "操作失败，请刷新页面重试"
