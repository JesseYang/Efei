#= require 'utility/ajax'
#= require "extensions/page_notification"

$ ->
  $("#confirm").click ->
    $(".question-content-div").each ->
      question_id = $(this).attr("data-id")
      question_type = $(this).find(".question-type").val()
      question_difficulty = $(this).find(".question-difficulty").val()
      console.log question_type
      console.log question_difficulty
      $.putJSON(
        "/teacher/questions/#{question_id}/update_info",
        {
          question_type: question_type
          question_difficulty: question_difficulty
        },
        (retval) ->
          window.location.reload()
      )

