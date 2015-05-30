$ ->
  weixin_jsapi_authorize(["closeWindow"])

  $(".close-page").click ->
    alert("aaa")
    wx.closeWindow()
