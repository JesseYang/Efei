$ ->
  weixin_jsapi_authorize(["closeWindow"])

  $(".close-page").click ->
    wx.closeWindow();
