(($) ->
  $.fn.up_key_down = (fun) ->
    that = this
    this.keydown (e) ->
      code = ((if e.keyCode then e.keyCode else e.which))
      if code is 38
        fun.call(that)
    this
) jQuery