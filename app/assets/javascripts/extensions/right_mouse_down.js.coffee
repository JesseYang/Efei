(($) ->
  $.fn.right_mouse_down = (fun) ->
    $("body").bind "contextmenu", ->
      false
    that = this
    this.mousedown (e) ->
      if e.button is 2
        fun.call(that, e)
    this
) jQuery