(($) ->
  $.fn.down_key_down = (fun) ->
    that = this
    this.keydown (e) ->
      code = ((if e.keyCode then e.keyCode else e.which))
      if code is 40
        fun.call(that)
      e.stopPropagation()
    this
) jQuery