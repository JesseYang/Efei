#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require "./_templates/books_ul"
#= require "./_templates/paper_table"
#= require "utility/_templates/paginator_mini"
#= require "extensions/page_notification"
$ ->

  $("#homework-selector select").change ->
    if $(this).val() != -1
      window.location.href = "/teacher/questions/" + window.question_id + "/detail?homework_id=" + $(this).val()

  $(".image-wrapper").mouseenter ->
    $(this).find("a").removeClass "hide"
  $(".image-wrapper").mouseleave ->
    $(this).find("a").addClass "hide"

  $(".image-wrapper a").click ->
    index = $(this).attr("data-index")
    qid = $(this).attr("data-id")
    ele = $(this).closest(".image-wrapper")
    $.deleteJSON(
      '/teacher/questions/' + qid + "/remove_snapshot_image",
      {
        index: index
      },
      (retval) ->
        if !retval.success
          $.page_notification("服务器出错，请刷新重试")
        else
          ele.remove()
    )

