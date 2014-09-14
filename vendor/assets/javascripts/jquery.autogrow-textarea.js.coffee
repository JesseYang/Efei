(($) ->
  
  ###*
  Auto-growing textareas; technique ripped from Facebook
  
  http://github.com/jaz303/jquery-grab-bag/tree/master/javascripts/jquery.autogrow-textarea.js
  ###
  $.fn.autogrow = (options) ->
    @filter("textarea").each ->
      self = this
      $self = $(self)
      minHeight = $self.height()
      noFlickerPad = (if $self.hasClass("autogrow-short") then 0 else parseInt($self.css("lineHeight")) or 0)
      shadow = $("<div></div>").css(
        position: "absolute"
        top: -10000
        left: -10000
        width: $self.width()
        fontSize: $self.css("fontSize")
        fontFamily: $self.css("fontFamily")
        fontWeight: $self.css("fontWeight")
        lineHeight: $self.css("lineHeight")
        resize: "none"
        "word-wrap": "break-word"
      ).appendTo(document.body)
      update = (event) ->
        times = (string, number) ->
          i = 0
          r = ""

          while i < number
            r += string
            i++
          r

        val = self.value.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/&/g, "&amp;").replace(/\n$/, "<br/>&nbsp;").replace(/\n/g, "<br/>").replace(RegExp(" {2,}", "g"), (space) ->
          times("&nbsp;", space.length - 1) + " "
        )
        
        # Did enter get pressed?  Resize in this keydown event so that the flicker doesn't occur.
        val += "<br />"  if event and event.data and event.data.event is "keydown" and event.keyCode is 13
        shadow.css "width", $self.width()
        shadow.html val + ((if noFlickerPad is 0 then "..." else "")) # Append '...' to resize pre-emptively.
        $self.height Math.max(shadow.height() + noFlickerPad, minHeight)
        return

      $self.change(update).keyup(update).keydown
        event: "keydown"
      , update
      $(window).resize update
      update()
      return


  return
) jQuery
