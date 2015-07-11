$ ->
  weixin_jsapi_authorize(["closeWindow"])
  $(".btn-exit").click ->
    wx.closeWindow()
