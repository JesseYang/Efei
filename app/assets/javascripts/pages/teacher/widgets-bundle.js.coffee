#= require 'extensions/out_click'
#= require 'extensions/up_key_down'
#= require 'extensions/down_key_down'
$(document).ready ->
  $("#div1").out_click ->
    console.log "click out of div1"
    console.log $(this).height()


  $("body").up_key_down ->
    console.log "up key down"

  $("body").down_key_down ->
    console.log "down key down"
