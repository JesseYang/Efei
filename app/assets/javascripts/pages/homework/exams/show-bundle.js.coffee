$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $(".test").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
