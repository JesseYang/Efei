$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $(".bind-btn").click ->
    alert("aaa")
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        alert(result)
