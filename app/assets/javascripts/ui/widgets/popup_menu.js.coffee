#= require ./_templates/popup_menu
(($) ->
  $.widget "efei.popup_menu",
    options:
      content: [
        { text: "create new" }
        { text: "delete" }
      ]
      id: ""
      name: ""
      type: ""
      pos: [0, 0]
    
    _create: ->
      # first close prevous popup_menu if there is any
      e = jQuery.Event "mousedown.popup_menu",
        which: 1
        pageX: this.options.pos[0]
        pageY: this.options.pos[1]
      $("body").trigger e

      this.element.append(this.hbs(this.options))
      this.element.addClass("popup-menu")

      page_width = $(window).width()
      page_height = $(window).height()
      div_width = this.element.width()
      div_height = this.element.height()
      if this.options.pos[0] + div_width < page_width
        div_loc_x = this.options.pos[0]
      else
        div_loc_x = this.options.pos[0] - div_width + 1
      if this.options.pos[1] + div_height < page_height
        div_loc_y = this.options.pos[1]
      else
        div_loc_y = page_height - div_height - 5
      

      this.element.css("left", div_loc_x)
      this.element.css("top", div_loc_y)
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
      $("body").off "mousedown.popup_menu"
      this.element.text("")

) jQuery