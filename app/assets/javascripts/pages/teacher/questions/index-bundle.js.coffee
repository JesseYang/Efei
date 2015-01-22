#= require 'utility/ajax'
#= require "extensions/page_notification"
$ ->
  if window.scope == "personal"
    $("#personal").attr("checked", true)
  else if window.scope == "public"
    $("#public").attr("checked", true)
  else
    $("#personal").attr("checked", true)
    $("#public").attr("checked", true)

