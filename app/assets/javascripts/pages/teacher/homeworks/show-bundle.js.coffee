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
    $("#replaceModal .question-download-url").attr("href", "/teacher/questions/#{qid}/export")

  $(".insert-btn").click ->
    $("#insertModal").modal("show")
    qid = $(this).closest(".btn-group").attr("data-qid")
    $("#insertModal").find("#question_id").val(qid)

  reorder = ->
    question_id_ary = [ ]
    $(".content-div").each ->
      qid = $(this).attr("data-question-id")
      question_id_ary.push qid
    console.log question_id_ary
    $.putJSON "/teacher/homeworks/#{window.homework_id}/reorder", {question_id_ary: question_id_ary}, (data) ->
      if !data.success
        $.page_notification "操作失败，请刷新页面重试"


  $(".move-up-btn").click ->
    ele = $(this).closest(".content-div")
    prev_content = ele.prev()
    if !prev_content.hasClass("content-div")
      return
    ele = $(this).closest(".content-div").detach()
    ele.insertBefore(prev_content)
    reorder()

  $(".move-down-btn").click ->
    ele = $(this).closest(".content-div")
    next_content = ele.next()
    if !next_content.hasClass("content-div")
      return
    ele = $(this).closest(".content-div").detach()
    ele.insertAfter(next_content)
    reorder()

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
      content: "正在替换题目，请稍候"

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
      content: "正在插入题目，请稍候"

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
