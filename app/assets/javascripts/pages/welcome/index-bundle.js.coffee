#= require 'unslider'

$ ->
  $('#screenshots').unslider();
  $('#pc-screenshots').unslider();

  $("#android-link-wrapper a").click ->
  	window.location.href = "/students/android_app"

  $("#ios-link-wrapper a").click ->
  	window.location.href = "/students/ios_app"
