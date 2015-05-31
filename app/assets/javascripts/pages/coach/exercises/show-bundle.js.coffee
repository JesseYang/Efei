#= require "jweixin-1.0.0"
#= require "utility/ajax"
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

  $(".save-btn").click ->
    wx.uploadImage
      localId: $(".student-answer-content img").attr("src") # 需要上传的图片的本地ID，由chooseImage接口获得
      isShowProgressTips: 1 # 默认为1，显示进度提示
      success: (res) ->
        serverId = res.serverId # 返回图片的服务器端ID
        alert(serverId)


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
