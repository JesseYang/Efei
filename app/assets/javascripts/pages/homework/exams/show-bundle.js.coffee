$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $(".test").click ->
    alert("aaa")
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr

  $(".test").trigger("click")
