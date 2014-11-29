$ ->

  $(".expand-link").click (event) ->
    if $(this).attr("data-expand") == "false"
      $(this).closest(".question-content-div").height("auto")
      $(this).attr("data-expand", true)
      $(this).text("收起")
    else
      $(this).closest(".question-content-div").height("60px")
      $(this).attr("data-expand", false)
      $(this).text("展开")
