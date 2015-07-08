$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  wx.scanQRCode
    needResult: 1
    scanType: ["qrCode"]
    success: (res) ->
      result = res.resultStr
      $(".ret-label").text(result)
