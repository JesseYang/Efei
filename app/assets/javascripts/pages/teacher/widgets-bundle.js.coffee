#= require 'extensions/out_click'
#= require 'extensions/up_key_down'
#= require 'extensions/down_key_down'
#= require 'extensions/right_mouse_down'
#= require 'ui/widgets/popup_menu'
$(document).ready ->

  $("#div1").right_mouse_down (x, y) ->
    console.log "right mouse down"
    popup_menu = $("<div />").appendTo("body")
    popup_menu.popup_menu(pos: [x, y])
