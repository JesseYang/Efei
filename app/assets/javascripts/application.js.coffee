#= require jquery
#= require jquery.autogrow-textarea
#= require jquery_ujs
#= require jquery-ui
#= require handlebars.runtime
#= require bootstrap.min
#= require sugar.min
#= require utility/querilayer
#= require utility/console
#= require jquery.jesse.notification
#= require jquery.placeholder
#= require respond
#= require html5shiv

$ ->
  $("#app-notification").notification()
  $("input").placeholder()
  $("textarea").placeholder()
