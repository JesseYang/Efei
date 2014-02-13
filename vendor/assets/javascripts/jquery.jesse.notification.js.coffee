(($, window, document) ->
  $.fn.notification = (options) ->
    opts = $.extend( {}, $.fn.notification.defaults, options )
    that = this

    if opts.content != ""
      this.find("span").html(opts.content)

    width = this.width()
    if width <= 0
      that.css "visibility", "hidden"
    else
      that.css "visibility", "visible"
      that.css "margin-left", - width / 2
      that.show()
      timer = window.setTimeout(->
        that.fadeOut "slow"
      , opts.delay)

    that.hover (->
      return if !that.is(':visible')
      window.clearTimeout(timer)
    ), ->
      return if !that.is(':visible')
      timer = window.setTimeout(->
        that.fadeOut "slow"
        that.css "visibility", "visible"
      , opts.delay)

  $.fn.notification.defaults = {
    delay: 1000,
    content: ""
  }
) jQuery, window, document
