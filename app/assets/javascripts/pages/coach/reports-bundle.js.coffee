#= require "./reports/_templates/para_wrapper"
#= require "./reports/_templates/image_wrapper"
#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require 'jQueryRotate'
$ ->
  window.to_submit = false
  window.current_content = null
  weixin_jsapi_authorize(["chooseImage", "uploadImage", "previewImage", "startRecord", "stopRecord", "translateVoice", "scanQRCode"])

  $(".new-paragraph-btn").click ->
    new_para = $(HandlebarsTemplates["para_wrapper"]({ }))
    $(".content-wrapper").append(new_para)

  $("body").on "click", ".delete", (event) ->
    ele = $(event.target).closest(".one-content")
    ele.remove()

  $("body").on "click", ".voice-input", (event) ->
    $(".one-content").attr("data-current", "false")
    ele = $(event.target).closest(".one-content")
    window.current_content = ele
    $("#voiceInput").modal("show")

  $("#voiceInput #start-btn").click ->
    wx.startRecord()
    $("#voiceInput #start-btn").attr("disabled", true)
    $("#voiceInput #stop-btn").attr("disabled", false)
    $(".record-tip").removeClass("hide")

  $("#voiceInput #stop-btn").click ->
    $("#voiceInput #start-btn").attr("disabled", false)
    $("#voiceInput #stop-btn").attr("disabled", true)
    replace = $("#voiceInput #replace_current").prop("checked")
    $("#voiceInput").modal("hide")
    $(".record-tip").addClass("hide")
    wx.stopRecord
      success: (res) ->
        wx.translateVoice
          localId: res.localId
          isShowProgressTips: 1
          success: (res) ->
            textarea = window.current_content.find("textarea")
            if replace
              textarea.text(res.translateResult)
            else
              textarea.text(textarea.text() + res.translateResult)

  $(".new-image-btn").click ->
    wx.chooseImage
      success: (res) ->
        localIds = res.localIds
        new_image = $(HandlebarsTemplates["image_wrapper"]({ }))
        $(".content-wrapper").append(new_image)
        new_image.find("img").attr("src", localIds)

  $("body").on "click", ".move-up", (event) ->
    ele = $(event.target).closest(".one-content")
    prev = ele.prev()
    if prev.hasClass("one-content")
      ele.remove()
      ele.insertBefore(prev)

  $("body").on "click", ".move-down", (event) ->
    ele = $(event.target).closest(".one-content")
    next = ele.next()
    if next.hasClass("one-content")
      ele.remove()
      ele.insertAfter(next)

  $("body").on "click", ".turn", (event) ->
    has_class = $(event.target).closest(".turn").hasClass("btn-primary")
    $(event.target).closest(".one-content").find(".turn").removeClass("btn-primary")
    if !has_class
      $(event.target).closest(".turn").addClass("btn-primary")

  $(".save-btn").click ->
    save_report()

  save_report = ->
    window.content = [ ]
    i = 0
    window.uploaded_image_number = 0
    window.text_para_number = 0
    window.existing_image_number = 0
    $(".one-content").each ->
      ele = { }
      ele.index = i
      i++
      if $(this).hasClass("para-wrapper")
        ele.type = "text"
        ele.value = $(this).find("textarea").val()
        window.content.push(ele)
        window.text_para_number += 1
      else
        ele.type = "image"
        if $(this).hasClass("new-image")
          wx.uploadImage
            localId: $(this).find("img").attr("src")
            isShowProgressTips: 0
            success: (res) ->
              ele.value = res.serverId
              ele.image_type = "new"
              ele.rotate = $(this).find(".btn-group .btn-primary").attr("data-rotate")
              window.content.push(ele)
              window.uploaded_image_number += 1
              if window.uploaded_image_number == $(".new-image").length
                send_save_report_request()
        else
          ele.image_type = "existing"
          ele.value = $(this).find("img").attr("data-serverId")
          ele.rotate = $(this).find(".btn-group .btn-primary").attr("data-rotate")
          window.content.push(ele)
          window.existing_image_number += 1
      send_save_report_request()

  send_save_report_request = ->
    if window.uploaded_image_number != $(".new-image").length || window.text_para_number != $(".para-wrapper").length || window.existing_image_number != $(".existing-image").length
      return
    if window.report_id == ""
      $.postJSON "/coach/reports",
        {
          content: content,
          student_id: window.student_id,
          local_course_id: window.local_course_id
        }, (data) ->
          if data.success
            $.page_notification "保存成功"
            window.report_id = data.report_id
            submit()
          else
            $.page_notification "操作失败，请刷新页面重试"
    else
      $.putJSON "/coach/reports/#{window.report_id}",
        {
          content: content
        }, (data) ->
          if data.success
            $.page_notification "保存成功"
            submit()
          else
            $.page_notification "操作失败，请刷新页面重试"

  $(".submit-btn").click ->
    window.to_submit = true
    save_report()

  submit = ->
    if window.to_submit != true
      return
    $.putJSON "/coach/reports/#{window.report_id}/submit",
      { }, (data) ->
        if data.success
          $.page_notification "提交成功"
          window.to_submit = false
        else
          $.page_notification "操作失败，请刷新页面重试"
