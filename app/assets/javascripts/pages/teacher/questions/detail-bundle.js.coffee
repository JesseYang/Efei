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