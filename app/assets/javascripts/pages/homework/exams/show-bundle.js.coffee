$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  wx.ready ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
