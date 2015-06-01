#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require 'jQueryRotate'
$ ->

  weixin_jsapi_authorize(["chooseImage", "uploadImage", "previewImage", "startRecord", "stopRecord", "translateVoice", "scanQRCode"])

  $(".answer-item-ul a").click ->
    $(this).closest(".answer-item-ul").find("i").removeClass("selected")
    $(this).find("i").addClass("selected")

  $(".get-answer-content-photo").click ->
    wx.chooseImage
      success: (res) ->
        localIds = res.localIds
        $(".student-answer-content img").attr("src", localIds)
        $(".student-answer-content img").removeClass("hide")
        $(".student-answer-content img").attr("data-update", "true")
        $(".student-answer-content .btn-group").removeClass("hide")

  $(".get-coach-comment-photo").click ->
    wx.chooseImage
      success: (res) ->
        localIds = res.localIds
        $(".coach-comment img").attr("src", localIds)
        $(".coach-comment img").removeClass("hide")
        $(".coach-comment img").attr("data-update", "true")
        $(".coach-comment .btn-group").removeClass("hide")

  $(".get-coach-comment-voice").click ->
    $("#voiceInput").modal("show")

  $("#voiceInput #start-btn").click ->
    wx.startRecord()
    $("#voiceInput #start-btn").attr("disabled", true)
    $("#voiceInput #stop-btn").attr("disabled", false)
    $(".record-tip").removeClass("hide")

  $("#voiceInput #stop-btn").click ->
    $("#voiceInput #start-btn").attr("disabled", false)
    $("#voiceInput #stop-btn").attr("disabled", true)
    window.replace = $("#voiceInput #replace_current").prop("checked")
    $("#voiceInput").modal("hide")
    $(".record-tip").addClass("hide")
    wx.stopRecord
      success: (res) ->
        wx.translateVoice
          localId: res.localId
          isShowProgressTips: 1
          success: (res) ->
            if window.replace
              $(".coach-comment-area").text(res.translateResult)
            else
              $(".coach-comment-area").text($(".coach-comment-area").text() + res.translateResult)

  $(".save-btn").click ->
    if $(".student-answer-content img").attr("data-update") == "true"
      # upload the answer content image
      if $(".student-answer-content img").hasClass("hide")
        # user delete the image
        window.answer_content_img_serverId = ""
        upload_comment_img()
      else
        # user add a new image
        wx.uploadImage
          localId: $(".student-answer-content img").attr("src")
          isShowProgressTips: 1
          success: (res) ->
            window.answer_content_img_serverId = res.serverId
            upload_comment_img()
    else
      upload_comment_img()

  upload_comment_img = ->
    if $(".coach-comment img").attr("data-update") == "true"
      # upload the coach comment image
      if $(".coach-comment img").hasClass("hide")
        # user delete the image
        window.coach_comment_img_serverId = ""
        upload_answer_content()
      else
        # user add a new image
        wx.uploadImage
          localId: $(".coach-comment img").attr("src")
          isShowProgressTips: 1
          success: (res) ->
            window.coach_comment_img_serverId = res.serverId
            upload_answer_content()
    else
      upload_answer_content()

  upload_answer_content = ->
    answer_index = $(".answer-item-ul .selected").attr("data-index")
    answer_content_img_rotate = $(".student-answer-content .btn-group .btn-primary").attr("data-rotate")
    coach_comment_img_rotate = $(".coach-comment .btn-group .btn-primary").attr("data-rotate")
    $.putJSON "/coach/exercises/#{window.question_id}",
      {
        student_id: student_id,
        exercise_id: exercise_id,
        answer_content: {
          answer_index: answer_index,
          comment: $("#comment").val(),
          answer_content_img_serverId: window.answer_content_img_serverId,
          answer_content_img_rotate: answer_content_img_rotate,
          coach_comment_img_serverId: window.coach_comment_img_serverId,
          coach_comment_img_rotate: coach_comment_img_rotate
        }
      }, (data) ->
        if data.success
          $.page_notification "保存成功"
        else
          $.page_notification "操作失败，请刷新页面重试"


  $(".student-answer-content .delete").click ->
    $(".student-answer-content img").addClass("hide")
    $(".student-answer-content img").attr("data-update", "true")
    $(".student-answer-content .btn-group").addClass("hide")

  $(".student-answer-content .turn").click ->
    $(".student-answer-content .turn").removeClass("btn-primary")
    $(this).addClass("btn-primary")

  $(".coach-comment .delete").click ->
    $(".coach-comment img").addClass("hide")
    $(".coach-comment img").attr("data-update", "true")
    $(".coach-comment img").attr("src", "")
    $(".coach-comment .btn-group").addClass("hide")

  $(".coach-comment .turn").click ->
    $(".coach-comment .turn").removeClass("btn-primary")
    $(this).addClass("btn-primary")


###
  $(".photo").click ->
    wx.chooseImage
      success: (res) ->
        localIds = res.localIds # 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片

  $(".start").click ->
    wx.startRecord()

  $(".stop").click ->
    wx.stopRecord
      success: (res) ->
        window.localId = res.localId;

  $(".translate").click ->
    wx.translateVoice
      localId: window.localId # 需要识别的音频的本地Id，由录音相关接口获得
      isShowProgressTips: 1 # 默认为1，显示进度提示
      success: (res) ->
        alert(res.translateResult); # 语音识别的结果

  $(".qrcode").click ->
    wx.scanQRCode
      needResult: 1 # 默认为0，扫描结果由微信处理，1则直接返回扫描结果，
      scanType: ["qrCode","barCode"] # 可以指定扫二维码还是一维码，默认二者都有
      success: (res) ->
        result = res.resultStr # 当needResult 为 1 时，扫码返回的结果
        alert(result)
###
