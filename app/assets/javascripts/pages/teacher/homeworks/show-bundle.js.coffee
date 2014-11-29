#= require 'utility/ajax'
#= require "extensions/page_notification"

$ ->
  $(".content-div").hover (->
    $(this).find(".question-operation-div").removeClass "hide"
  ), (->
    $(this).find(".question-operation-div").addClass "hide"
  )

  $(".replace-btn").click ->
    $("#replaceModal").modal("show")

  $(".insert-btn").click ->
    $("#insertModal").modal("show")
