(($) ->
  $.fn.out_click = (fun) ->
    this.click (e) ->
      e.stopPropagation()
    that = this
    $("body").click ->
      fun.call(that)
    this
) jQuery