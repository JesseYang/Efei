#= require 'utility/ajax'
#= require "extensions/page_notification"

$ ->

  scroll_to_question = (question_id) ->
    ele = $("*[data-question-id=" + question_id + "]");
    $('html, body').animate({
      scrollTop: ele.offset().top
    })

  if window.scroll != ""
    scroll_to_question(window.scroll)

  $(".content-div").hover (->
    $(this).find(".question-operation-div").removeClass "hide"
  ), (->
    $(this).find(".question-operation-div").addClass "hide"
  )

  $(".question-separator").hover (->
    $(this).find(".combine-questions").removeClass "hide"
  ), (->
    $(this).find(".combine-questions").addClass "hide"
  )

  $(".combine-questions").dblclick ->
    separator = $(this).closest(".question-separator")
    prev_q_ele = separator.prev()
    next_q_ele = separator.next()
    q_id_1 = prev_q_ele.attr("data-question-id")
    q_id_2 = next_q_ele.attr("data-question-id")
    $("#combineModal").modal("show")
    $("#combineModal").attr("data-q-id-1", q_id_1)
    $("#combineModal").attr("data-q-id-2", q_id_2)

  combine_questions = ->
    q_id_1 = $("#combineModal").attr("data-q-id-1")
    q_id_2 = $("#combineModal").attr("data-q-id-2")
    $.putJSON(
      "/teacher/homeworks/#{window.homework_id}/combine_questions",
      {
        q_id_1: q_id_1
        q_id_2: q_id_2
      },
      (data) ->
        if data.success
          $.page_notification("合并完毕，正在刷新")
          window.location.href = "/teacher/homeworks/#{window.homework_id}?scroll=#{data.question_id}"
        else
          $.page_notification("服务器出错，请刷新重试")
    )

  $("#combineModal .ok").click ->
    combine_questions()
    $("#combineModal").modal("hide")

  $(".video-btn").click ->
    $("#videoModal").modal("show")
    qid = $(this).closest(".btn-group").attr("data-qid")
    video_url = $(this).closest(".btn-group").attr("data-videourl")
    video_id = $(this).closest(".btn-group").attr("data-vid")
    duration = $(this).closest(".btn-group").attr("data-duration")
    if video_url == undefined || video_url == ""
      $(".question-video").addClass("hide")
      $(".video-name").addClass("hide")
    else
      $(".question-video").removeClass("hide")
      $(".question-video").attr("src", video_url)
      $(".video-name").removeClass("hide")
      $(".video-name").text("视频名称：" + video_url)
      $(".video-detail-url").attr("href", "/admin/videos/#{video_id}?homework_id=#{window.homework_id}&question_id=#{qid}")
    $("#videoModal form #duration").val(duration)
    $("#videoModal form").attr("action", "/teacher/questions/" + qid + "/update_video")

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
    scroll_to_question(ele.attr("data-question-id"))
    reorder()

  $(".move-down-btn").click ->
    ele = $(this).closest(".content-div")
    next_content = ele.next()
    if !next_content.hasClass("content-div")
      return
    ele = $(this).closest(".content-div").detach()
    ele.insertAfter(next_content)
    scroll_to_question(ele.attr("data-question-id"))
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
