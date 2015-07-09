#= require json2
#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require jquery-migrate-1.2.1.min
#= require jquery.placeholder
#= require jquery.scrollUp.min
#= require jquery.cookie
#= require intro
#= require bootstrap-sprockets
#= require sugar.min
#= require utility/querilayer
#= require utility/console
#= require respond
#= require html5shiv
#= require handlebars.runtime
#= require ui/widgets/notification
#= require extensions/page_notification
#= require "jweixin-1.0.0"
#= require "jail"
#= require "jquery.dotdotdot.min"

$ ->
  if $.browser.msie && parseFloat($.browser.version) < 8
    setTimeout ->
      $('#browser').slideDown()
    , 500
  else
    $('#browser').remove();

  $.page_notification window.flash


  Handlebars.registerHelper "ifCond", (v1, v2, options) ->
    return options.fn(this)  if v1 is v2
    options.inverse this

  Handlebars.registerHelper "ifCondNot", (v1, v2, options) ->
    return options.fn(this)  if v1 is not v2
    options.inverse this
  
  $("input").placeholder()
  $("textarea").placeholder()

  $.scrollUp({
      animation: 'fade'
      activeOverlay: '#00FFFF'
      scrollImg: {
          active: true
          type: 'background'
          src: "image-url('top.png')"
      }
  })

  window.weixin_jsapi_authorize = (api_list, callback=undefined) ->
    $.getJSON "/weixin_js_signature?url=" + encodeURIComponent(window.location.href.split('#')[0]), (retval) ->
      if retval.success
        data = retval.data
        wx.config
          debug: true # 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
          appId: data.appid # 必填，公众号的唯一标识
          timestamp: data.timestamp # 必填，生成签名的时间戳
          nonceStr: data.noncestr # 必填，生成签名的随机串
          signature: data.signature # 必填，签名，见附录1
          jsApiList: api_list # 必填，需要使用的JS接口列表，所有JS接口列表见附录2
        if callback != undefined
          callback()
      else
        $.page_notification "服务器出错"
