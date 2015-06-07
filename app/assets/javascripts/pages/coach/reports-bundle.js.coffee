#= require "./reports/_templates/para_wrapper"
#= require "./reports/_templates/image_wrapper"
#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require 'jQueryRotate'
$ ->
  window.current_content = null
  weixin_jsapi_authorize(["chooseImage", "uploadImage", "previewImage", "startRecord", "stopRecord", "translateVoice", "scanQRCode"])

  $(".new-paragraph").click ->
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

  $(".new-image").click ->
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
