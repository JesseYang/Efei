#= require ./_templates/popup_menu
(($) ->
  $.widget "efei.popup_menu",
    options:
      content: "hahahahaha"
      pos: [0, 0]
    
    _create: ->
      this.element.append(this.hbs(this.options))
      this.element.addClass("popup-menu")
      this.element.css("left", this.options.pos[0])
      this.element.css("top", this.options.pos[1])
      that = this

      $("body").on "mousedown.popup_menu", (e) ->
        # check if mouse is over popup_menu
        x = e.pageX
        y = e.pageY
        left =  parseInt(that.element.css("left"), 10)
        right = left + parseInt(that.element.css("width"), 10)
        top = parseInt(that.element.css("top"), 10)
        bottom = top + parseInt(that.element.css("height"), 10)
        if x < left || x > right || y < top || y > bottom
          that.element.remove()

    hbs: (content, name) ->
      $(HandlebarsTemplates["ui/widgets/_templates/popup_menu"](content))

    _destroy: ->
      this.element.text("")

) jQuery