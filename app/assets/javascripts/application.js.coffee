#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require jquery-migrate-1.2.1.min
#= require bootstrap-sprockets
#= require sugar.min
#= require utility/querilayer
#= require utility/console
#= require jquery.placeholder
#= require respond
#= require html5shiv
#= require handlebars.runtime
#= require ui/widgets/notification

$ ->
  if $.browser.msie && parseFloat($.browser.version) < 8
    setTimeout ->
      $('#browser').slideDown()
    , 500
  else
    $('#browser').remove();
  
  $("input").placeholder()
  $("textarea").placeholder()
