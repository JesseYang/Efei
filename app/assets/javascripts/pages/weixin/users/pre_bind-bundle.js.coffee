#= require 'utility/ajax'
$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  $(".bind-btn").click ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        $.postJSON(
          '/weixin/users/bind',
          {
            student_id: result
          },
          (data) ->
            if !data.success
              window.location.href = data.url
            else
              $.page_notification("二维码不正确")
