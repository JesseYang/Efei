#= require "../admin/_templates/point_ele"
#= require 'utility/ajax'
$ ->

  refresh_canvas_size = ->
    w = $("video").width()
    h = $("video").height()
    $("canvas")[0].width = w
    $("canvas")[0].height = h

  refresh_canvas_size()

  $(".btn-update-snapshot").click ->
    question_id = $("#update_question_id").val()
    sid = $("#check-snapshot").attr("data-id")
    key_point = [ ]
    $("#check-snapshot .point-ul li").each ->
      key_point.push $(this).find("input").val()
    $.putJSON(
      '/admin/snapshots/' + sid,
      {
        key_point: key_point
        question_id
      },
      (retval) ->
        if !retval.success
          $.page_notification("服务器出错，请刷新重试")
        else
          $.page_notification("更新成功")
    )

  $(".btn-return-snapshots").click ->
    return_snapshot()

  return_snapshot = ->
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
    $("#check-snapshot").attr("data-id", sid)
    $.getJSON "/admin/snapshots/#{sid}", (data) ->
      if data.success
        refresh_canvas_size()
        $("canvas").removeClass("hide")
        $("video")[0].controls = false
        ctx = $("canvas")[0].getContext("2d")
        $("video")[0].currentTime = data.data.time
        $("#update_question_id").val(data.data.question_id)
        for key_point in data.data.key_point
          ctx.beginPath()
          ctx.rect(key_point.position[0]*$("canvas").width()-7.5, key_point.position[1]*$("canvas").height()-7.5, 15, 15)
          ctx.lineWidth = 2
          ctx.fillStyle = "#00FFFF"
          ctx.strokeStyle = "#00FFFF"
          ctx.stroke()
          $("#check-snapshot .point-ul").append("<li><input type=text class=form-control value=" + key_point.desc + "></li>")
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
    return_snapshot()
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
    $("#key-point-ul-title").removeClass("hide")

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
    $("#key-point-ul-title").removeClass("hide")

  $("canvas").dblclick ->
    ctx = $(this)[0].getContext("2d")
    ctx.clearRect(0, 0, $(this).width(), $(this).height())
    $(this).addClass("hide")
    $(".btn-select").attr("disabled", false)
    $("#new-snapshot .point-ul li").remove()
    $("#video-canvas-wrapper video")[0].controls = true
    $("#key-point-ul-title").addClass("hide")

  $("#tag_tag_type").change ->
    if $(this).val() == "4"
      $("#snapshot-selector-wrapper").removeClass("hide")
      $("#form-ele-wrapper").addClass("hide")
    else
      $("#snapshot-selector-wrapper").addClass("hide")
      $("#form-ele-wrapper").removeClass("hide")
