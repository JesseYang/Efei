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
    qid = $(this).closest(".btn-group").attr("data-qid")
    $("#replaceModal").find("#question_id").val(qid)

  $(".insert-btn").click ->
    $("#insertModal").modal("show")
    qid = $(this).closest(".btn-group").attr("data-qid")
    $("#insertModal").find("#question_id").val(qid)

  $("#replaceModal form").submit ->
    if $("#replaceModal #replace_homework_file").val() == ""
      notification = $("<div />").appendTo("#replaceModal") 
      notification.notification
        content: "请先选择要上传的文件"
      return false
    if !$("#replaceModal #replace_homework_file").val().match(/\.docx?$/)
      notification = $("<div />").appendTo("#replaceModal") 
      notification.notification
        content: "文件格式错误，请上传doc或者docx格式文件"
        delay: 2000
      return false
    notification = $("<div />").appendTo("#replaceModal") 
    notification.notification
      delay: 0
      content: "正在替换作业，请稍候"

  $("#insertModal form").submit ->
    if $("#insertModal #insert_homework_file").val() == ""
      notification = $("<div />").appendTo("#insertModal") 
      notification.notification
        content: "请先选择要上传的文件"
      return false
    if !$("#insertModal #insert_homework_file").val().match(/\.docx?$/)
      notification = $("<div />").appendTo("#insertModal") 
      notification.notification
        content: "文件格式错误，请上传doc或者docx格式文件"
        delay: 2000
      return false
    notification = $("<div />").appendTo("#insertModal") 
    notification.notification
      delay: 0
      content: "正在替换作业，请稍候"

  replaceIntervalFunc = ->
    $('#replace-homework-name').html $('#replace_homework_file').val()
  $("#browser-replace-homework-click").click ->
    $("#replace_homework_file").click()
    setInterval(replaceIntervalFunc, 1)

  insertIntervalFunc = ->
    $('#insert-homework-name').html $('#insert_homework_file').val()
  $("#browser-insert-homework-click").click ->
    $("#insert_homework_file").click()
    setInterval(insertIntervalFunc, 1)