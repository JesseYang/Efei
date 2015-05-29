#= require "jweixin-1.0.0"
#= require "utility/ajax"
$ ->
  window.authorize = (api_list) ->
    $.getJSON "/weixin_js_signature?url=" + window.location.href.split('#')[0], (retval) ->
      if retval.success
        data = retval.data
        wx.config
          debug: true # 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
          appId: data.appid # 必填，公众号的唯一标识
          timestamp: data.timestamp # 必填，生成签名的时间戳
          nonceStr: data.noncestr # 必填，生成签名的随机串
          signature: data.signature # 必填，签名，见附录1
          jsApiList: api_list # 必填，需要使用的JS接口列表，所有JS接口列表见附录2
      else
        $.page_notification "服务器出错"
