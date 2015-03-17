#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require jquery-migrate-1.2.1.min
#= require jquery.placeholder
#= require jquery.scrollUp.min
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
          src: 'assets/top.png'
      }
  })
