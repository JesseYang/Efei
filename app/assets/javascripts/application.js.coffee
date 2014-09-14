#= require jquery
#= require jquery.autogrow-textarea
#= require jquery_ujs
#= require bootstrap.min
#= require sugar.min
#= require utility/querilayer
#= require utility/console
#= require jquery.jesse.notification
#= require jquery.placeholder

$ ->
  $("#app-notification").notification()
  $("input").placeholder()
  $("textarea").placeholder()
