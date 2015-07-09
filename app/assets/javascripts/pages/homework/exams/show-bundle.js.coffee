$ ->

  scan = ->
    alert("aaa")
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr

  weixin_jsapi_authorize(["scanQRCode"], scan)
