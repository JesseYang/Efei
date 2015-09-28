#= require "../admin/_templates/point_ele"
#= require 'utility/ajax'
$ ->

  refresh_canvas_size = ->
    w = $("video").width()
    h = $("video").height()
    $("canvas")[0].width = w
    $("canvas")[0].height = h

  refresh_canvas_size()

  $(".btn-return-screeshots").click ->
    $("#check-snapshot").addClass("hide")
    $("#check-snapshot .point-ul").empty()
    $("#snapshots").removeClass("hide")
    ctx = $("canvas")[0].getContext("2d")
    ctx.clearRect(0, 0, $(this).width(), $(this).height())
    $("canvas").addClass("hide")
    $("video")[0].controls = true

  $(".btn-check-snapshot").click ->
    $("#snapshots").addClass("hide")
    $("#check-snapshot").removeClass("hide")
    sid = $(this).attr("data-id")
    $.getJSON "/admin/snapshots/#{sid}", (data) ->
      if data.success
        refresh_canvas_size()
        $("canvas").removeClass("hide")
        $("video")[0].controls = false
        ctx = $("canvas")[0].getContext("2d")
        $("video")[0].currentTime = data.data.time
        for key_point in data.data.key_point
          ctx.beginPath()
          ctx.rect(key_point.position[0]*$("canvas").width()-7.5, key_point.position[1]*$("canvas").height()-7.5, 15, 15)
          ctx.lineWidth = 2
          ctx.fillStyle = "#00FFFF"
          ctx.strokeStyle = "#00FFFF"
          ctx.stroke()
          $("#check-snapshot .point-ul").append("<li>" + key_point.desc + "</li>")
        console.log data.data
      else
        $.page_notification "服务器出错"

  $("#new-snapshot .btn-cancel").click ->
    $("#new-snapshot").addClass("hide")
    $("#snapshots").removeClass("hide")
    ctx = $("canvas")[0].getContext("2d")
    ctx.clearRect(0, 0, $("canvas").width(), $("canvas").height())
    $("canvas").addClass("hide")
    $(".btn-select").attr("disabled", false)
    $("#new-snapshot .point-ul li").remove()
    $("#video-canvas-wrapper video")[0].controls = true

  $(".btn-new-snapshot").click ->
    $("#new-snapshot").removeClass("hide")
    $("#snapshots").addClass("hide")

  $("#new-snapshot form").submit ->
    key_point = [ ]
    $("#new-snapshot .point-ul li").each ->
      key_point.push {
        position: [$(this).find(".x").text(), $(this).find(".y").text()]
        desc: $(this).find("input").val()
      }
    $.postJSON(
      '/admin/snapshots/',
      {
        video_id: window.video_id
        time: $("#video-canvas-wrapper video")[0].currentTime
        key_point: key_point
        question_id: $("#new-snapshot #question_id").val()
      },
      (retval) ->
        if !retval.success
          $.page_notification("服务器出错，请刷新重试")
        else
          window.location.href = "/admin/videos/#{window.video_id}"
    )
    false

  $(".btn-select").click ->
    refresh_canvas_size()
    $("canvas").removeClass("hide")
    $(this).attr("disabled", true)
    $("video")[0].controls = false

  $("canvas").click ->
    pre_x = $("#video-canvas-wrapper video")[0].getBoundingClientRect().left
    pre_y = $("#video-canvas-wrapper video")[0].getBoundingClientRect().top
    x = event.x - pre_x
    y = event.y - pre_y
    ctx = $(this)[0].getContext("2d")
    ctx.beginPath()
    ctx.rect(x-7.5, y-7.5, 15, 15)
    ctx.lineWidth = 2
    ctx.fillStyle = "#00FFFF"
    ctx.strokeStyle = "#00FFFF"
    ctx.stroke()
    point_ele_data = {
      x: x / $("video").width()
      y: y / $("video").height()
    }
    point_ele = $(HandlebarsTemplates["point_ele"](point_ele_data))
    $("#new-snapshot .point-ul").append(point_ele)

  $("canvas").dblclick ->
    ctx = $(this)[0].getContext("2d")
    ctx.clearRect(0, 0, $(this).width(), $(this).height())
    $(this).addClass("hide")
    $(".btn-select").attr("disabled", false)
    $("#new-snapshot .point-ul li").remove()
    $("#video-canvas-wrapper video")[0].controls = true

  $("#tag_tag_type").change ->
    if $(this).val() == "4"
      $("#snapshot-selector-wrapper").removeClass("hide")
      $("#form-ele-wrapper").addClass("hide")
    else
      $("#snapshot-selector-wrapper").addClass("hide")
      $("#form-ele-wrapper").removeClass("hide")








  $(".admin-nav .courses").addClass("active")

  $(".edit-lesson").click ->
    $("#editLesson").modal("show")
    $("#editLesson form").attr("action", "/admin/lessons/" + $(this).closest("tr").attr("data-id"))
    $("#editLesson #lesson_name").val($(this).closest("tr").find(".name-td").text())
    $("#editLesson #lesson_order").val($(this).closest("tr").attr("data-index"))
    $("#editLesson #lesson_pre_test_id").val($(this).closest("tr").attr("data-pretestid"))
    $("#editLesson #lesson_exercise_id").val($(this).closest("tr").attr("data-exerciseid"))
    $("#editLesson #lesson_post_test_id").val($(this).closest("tr").attr("data-posttestid"))
    false

  $(".btn-filter").click ->
    subject = $("#course_subject").val()
    type = $("#course_type").val()
    window.location.href = "/admin/courses?subject=#{subject}&type=#{type}"

  $(".btn-edit").click ->
    tr = $(this).closest("tr")
    $("#editCourse form").attr("action", "/admin/courses/#{tr.attr("data-id")}")
    $("#editCourse .course-name").text("编辑课程：" + tr.attr("data-name"))
    $("#editCourse #course_teacher_id").val(tr.attr("data-teacher-id"))
    $("#editCourse #course_subject").val(tr.attr("data-subject"))
    $("#editCourse #course_type").val(tr.attr("data-type"))
    $("#editCourse #course_name").val(tr.attr("data-name"))
    $("#editCourse #course_start_at").val(tr.attr("data-start-at"))
    $("#editCourse #course_end_at").val(tr.attr("data-end-at"))
    $("#editCourse #course_grade").val(tr.attr("data-grade"))
    $("#editCourse #course_desc").val(tr.attr("data-desc"))
    $("#editCourse #course_suggestion").val(tr.attr("data-suggestion"))
    $("#editCourse").modal("show")

  $("#course_selector").change ->
    val = $(this).val()
    $.getJSON "/admin/lessons/list?course_id=#{val}", (data) ->
      if data.success
        $("#lesson_selector").empty()
        $.each data.data, (k, v) ->
          $('#lesson_selector')
            .append($("<option></option>")
            .attr("value",v)
            .text(k)); 
      else
        $.page_notification "服务器出错"

  $("#lesson_selector").change ->
    val = $(this).val()
    $.getJSON "/admin/videos/list?lesson_id=#{val}", (data) ->
      if data.success
        $("#existing_video_content").empty()
        $.each data.data, (k, v) ->
          $('#existing_video_content')
            .append($("<option></option>")
            .attr("value",v)
            .text(k)); 
      else
        $.page_notification "服务器出错"
