#= require ./_templates/icon_buttons
(($) ->
  $.widget "efei.icon_buttons",
    options:
      buttons: []
      toggle: false
    
    _create: ->
      this.element = this.hbs(this.options)

      if this.options.buttons.length > 1
        this.element.find(".icon-btn:eq(0)").addClass('icon-btn-l')
        this.element.find(".icon-btn:eq(" + (this.options.buttons.length - 1) + ")").addClass('icon-btn-r')
      else if this.otions.buttons.length == 1
        this.element.find(".icon-btn").addClass("icon-btn-single")

      $.each(this.options.buttons, $.proxy( (i, btn) ->
        $widget = this
        $btn = $widget._getBtn(i)
        
        # tooltip
        $btn.tooltip({
          placement: 'bottom',
          # delay: {show: 500, hide: 0}  
          # DO NOT delay. Bug happens when the widget is destroyed before the tooltip shows
        });
        
        $btn.hover ->
          $('.icon', $btn).addClass(btn.name + '_active')
        , ->
          $('.icon', $btn).removeClass(btn.name + '_active')
        
        $btn.click ->
          if $widget._activeIndex == i
            return
          if btn.click
            btn.click(e)
        
        if this.options.toggle
          $btn.click ->
            if $widget._activeIndex == i
              return
            
            $current_btn = $widget._activeBtn()
            if $current_btn && $current_btn.length > 0
              $current_btn.removeClass('active')
              $('.icon', $current_btn).removeClass(
                $widget.options.buttons[$widget._activeIndex].name + '-active');
            
            $btn.addClass('active')
            $('.icon', $btn).addClass(btn.name + '-active')
            $widget._activeIndex = i
        
      , this))

    _activeIndex: -1

    _activeBtn: ->
      if this._activeIndex < 0
        return null
      return this._getBtn(this._activeIndex)
    
    _getBtn: (index) ->
      return this.element.find('.icon-btn button:eq(' + index + ')')
    
    trigger: (index) ->
      this._getBtn(index).trigger('click')

    hbs: (content) ->
      $(HandlebarsTemplates["ui/widgets/_templates/icon_buttons"](content))

    _destroy: ->
      $.each(this.options.buttons, $.proxy((i, btn) ->
        this._getBtn(i).tooltip('destroy')
      , this))
      this.element.text("")

) jQuery