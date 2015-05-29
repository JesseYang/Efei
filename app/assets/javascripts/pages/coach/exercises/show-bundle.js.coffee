#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require "layouts/coach-layout"
$ ->
  authorize(["chooseImage", "previewImage", "startRecord", "stopRecord", "translateVoice"])

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
      localId: window.localId, # 需要识别的音频的本地Id，由录音相关接口获得
      isShowProgressTips: 1, # 默认为1，显示进度提示
      success: (res) ->
        alert(res.translateResult); # 语音识别的结果
