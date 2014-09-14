#
#
#	jQuery Tags Input Plugin 1.3.3
#	
#	Copyright (c) 2011 XOXCO, Inc
#	
#	Documentation for this plugin lives here:
#	http://xoxco.com/clickable/jquery-tags-input
#	
#	Licensed under the MIT license:
#	http://www.opensource.org/licenses/mit-license.php
#
#	ben@xoxco.com
#
#
(($) ->
  delimiter = new Array()
  tags_callbacks = new Array()
  $.fn.doAutosize = (o) ->
    minWidth = $(this).data("minwidth")
    maxWidth = $(this).data("maxwidth")
    val = ""
    input = $(this)
    testSubject = $("#" + $(this).data("tester_id"))
    return  if val is (val = input.val())
    
    # Enter new content into testSubject
    escaped = val.replace(/&/g, "&amp;").replace(/\s/g, " ").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    testSubject.html escaped
    
    # Calculate new width + whether to change
    testerWidth = testSubject.width()
    newWidth = (if (testerWidth + o.comfortZone) >= minWidth then testerWidth + o.comfortZone else minWidth)
    currentWidth = input.width()
    isValidWidthChange = (newWidth < currentWidth and newWidth >= minWidth) or (newWidth > minWidth and newWidth < maxWidth)
    
    # Animate width
    input.width newWidth  if isValidWidthChange
    return

  $.fn.resetAutosize = (options) ->
    
    # alert(JSON.stringify(options));
    minWidth = $(this).data("minwidth") or options.minInputWidth or $(this).width()
    maxWidth = $(this).data("maxwidth") or options.maxInputWidth or ($(this).closest(".tagsinput").width() - options.inputPadding)
    val = ""
    input = $(this)
    testSubject = $("<tester/>").css(
      position: "absolute"
      top: -9999
      left: -9999
      width: "auto"
      fontSize: input.css("fontSize")
      fontFamily: input.css("fontFamily")
      fontWeight: input.css("fontWeight")
      letterSpacing: input.css("letterSpacing")
      whiteSpace: "nowrap"
    )
    testerId = $(this).attr("id") + "_autosize_tester"
    if not $("#" + testerId).length > 0
      testSubject.attr "id", testerId
      testSubject.appendTo "body"
    input.data "minwidth", minWidth
    input.data "maxwidth", maxWidth
    input.data "tester_id", testerId
    input.css "width", minWidth
    return

  $.fn.addTag = (value, options) ->
    options = jQuery.extend(
      focus: false
      callback: true
    , options)
    @each ->
      id = $(this).attr("id")
      tagslist = $(this).val().split(delimiter[id])
      tagslist = new Array()  if tagslist[0] is ""
      value = jQuery.trim(value)
      if options.unique
        skipTag = $(this).tagExist(value)
        
        #Marks fake input as not_valid to let styling it
        $("#" + id + "_tag").addClass "not_valid"  if skipTag is true
      else
        skipTag = false
      if value isnt "" and skipTag isnt true
        $("<span>").addClass("tag").append($("<span>").text(value).append("&nbsp;&nbsp;"), $("<a>",
          href: "#"
          title: "Removing tag"
          text: "x"
        ).click(->
          $("#" + id).removeTag escape(value)
        )).insertBefore "#" + id + "_addTag"
        tagslist.push value
        $("#" + id + "_tag").val ""
        if options.focus
          $("#" + id + "_tag").focus()
        else
          $("#" + id + "_tag").blur()
        $.fn.tagsInput.updateTagsField this, tagslist
        if options.callback and tags_callbacks[id] and tags_callbacks[id]["onAddTag"]
          f = tags_callbacks[id]["onAddTag"]
          f.call this, value
        if tags_callbacks[id] and tags_callbacks[id]["onChange"]
          i = tagslist.length
          f = tags_callbacks[id]["onChange"]
          f.call this, $(this), tagslist[i - 1]
      return

    false

  $.fn.removeTag = (value) ->
    value = unescape(value)
    @each ->
      id = $(this).attr("id")
      old = $(this).val().split(delimiter[id])
      $("#" + id + "_tagsinput .tag").remove()
      str = ""
      i = 0
      while i < old.length
        str = str + delimiter[id] + old[i]  unless old[i] is value
        i++
      $.fn.tagsInput.importTags this, str
      if tags_callbacks[id] and tags_callbacks[id]["onRemoveTag"]
        f = tags_callbacks[id]["onRemoveTag"]
        f.call this, value
      return

    false

  $.fn.tagExist = (val) ->
    id = $(this).attr("id")
    tagslist = $(this).val().split(delimiter[id])
    jQuery.inArray(val, tagslist) >= 0 #true when tag exists, false when not

  
  # clear all existing tags and import new ones from a string
  $.fn.importTags = (str) ->
    id = $(this).attr("id")
    $("#" + id + "_tagsinput .tag").remove()
    $.fn.tagsInput.importTags this, str
    return

  $.fn.tagsInput = (options) ->
    settings = jQuery.extend(
      interactive: true
      defaultText: "add a tag"
      minChars: 0
      width: "300px"
      height: "100px"
      autocomplete:
        selectFirst: false

      hide: true
      delimiter: ","
      unique: true
      removeWithBackspace: true
      placeholderColor: "#666666"
      autosize: true
      comfortZone: 20
      inputPadding: 6 * 2
    , options)
    @each ->
      $(this).hide()  if settings.hide
      id = $(this).attr("id")
      id = $(this).attr("id", "tags" + new Date().getTime()).attr("id")  if not id or delimiter[$(this).attr("id")]
      data = jQuery.extend(
        pid: id
        real_input: "#" + id
        holder: "#" + id + "_tagsinput"
        input_wrapper: "#" + id + "_addTag"
        fake_input: "#" + id + "_tag"
      , settings)
      delimiter[id] = data.delimiter
      if settings.onAddTag or settings.onRemoveTag or settings.onChange
        tags_callbacks[id] = new Array()
        tags_callbacks[id]["onAddTag"] = settings.onAddTag
        tags_callbacks[id]["onRemoveTag"] = settings.onRemoveTag
        tags_callbacks[id]["onChange"] = settings.onChange
      markup = "<div id=\"" + id + "_tagsinput\" class=\"tagsinput\"><div id=\"" + id + "_addTag\">"
      markup = markup + "<input id=\"" + id + "_tag\" value=\"\" data-default=\"" + settings.defaultText + "\" />"  if settings.interactive
      markup = markup + "</div><div class=\"tags_clear\"></div></div>"
      $(markup).insertAfter this
      $(data.holder).css "width", settings.width
      $(data.holder).css "min-height", settings.height
      $(data.holder).css "height", "100%"
      $.fn.tagsInput.importTags $(data.real_input), $(data.real_input).val()  unless $(data.real_input).val() is ""
      if settings.interactive
        $(data.fake_input).val $(data.fake_input).attr("data-default")
        $(data.fake_input).css "color", settings.placeholderColor
        $(data.fake_input).resetAutosize settings
        $(data.holder).bind "click", data, (event) ->
          $(event.data.fake_input).focus()
          return

        $(data.fake_input).bind "focus", data, (event) ->
          $(event.data.fake_input).val ""  if $(event.data.fake_input).val() is $(event.data.fake_input).attr("data-default")
          $(event.data.fake_input).css "color", "#000000"
          return

        if settings.autocomplete_url?
          autocomplete_options = source: settings.autocomplete_url
          for attrname of settings.autocomplete
            autocomplete_options[attrname] = settings.autocomplete[attrname]
          if jQuery.Autocompleter isnt `undefined`
            $(data.fake_input).autocomplete settings.autocomplete_url, settings.autocomplete
            $(data.fake_input).bind "result", data, (event, data, formatted) ->
              if data
                $("#" + id).addTag data[0] + "",
                  focus: true
                  unique: (settings.unique)

              return

          else if jQuery.ui.autocomplete isnt `undefined`
            $(data.fake_input).autocomplete autocomplete_options
            $(data.fake_input).bind "autocompleteselect", data, (event, ui) ->
              $(event.data.real_input).addTag ui.item.value,
                focus: true
                unique: (settings.unique)

              false

        else
          
          # if a user tabs out of the field, create a new tag
          # this is only available if autocomplete is not used.
          $(data.fake_input).bind "blur", data, (event) ->
            d = $(this).attr("data-default")
            if $(event.data.fake_input).val() isnt "" and $(event.data.fake_input).val() isnt d
              if (event.data.minChars <= $(event.data.fake_input).val().length) and (not event.data.maxChars or (event.data.maxChars >= $(event.data.fake_input).val().length))
                $(event.data.real_input).addTag $(event.data.fake_input).val(),
                  focus: true
                  unique: (settings.unique)

            else
              $(event.data.fake_input).val $(event.data.fake_input).attr("data-default")
              $(event.data.fake_input).css "color", settings.placeholderColor
            false

        
        # if user types a comma, create a new tag
        $(data.fake_input).bind "keypress", data, (event) ->
          if event.which is event.data.delimiter.charCodeAt(0) or event.which is 13
            event.preventDefault()
            if (event.data.minChars <= $(event.data.fake_input).val().length) and (not event.data.maxChars or (event.data.maxChars >= $(event.data.fake_input).val().length))
              $(event.data.real_input).addTag $(event.data.fake_input).val(),
                focus: true
                unique: (settings.unique)

            $(event.data.fake_input).resetAutosize settings
            false
          else $(event.data.fake_input).doAutosize settings  if event.data.autosize
          return

        
        #Delete last tag on backspace
        data.removeWithBackspace and $(data.fake_input).bind("keydown", (event) ->
          if event.keyCode is 8 and $(this).val() is ""
            event.preventDefault()
            last_tag = $(this).closest(".tagsinput").find(".tag:last").text()
            id = $(this).attr("id").replace(/_tag$/, "")
            last_tag = last_tag.replace(/[\s]+x$/, "")
            $("#" + id).removeTag escape(last_tag)
            $(this).trigger "focus"
          return
        )
        $(data.fake_input).blur()
        
        #Removes the not_valid class when user changes the value of the fake input
        if data.unique
          $(data.fake_input).keydown (event) ->
            $(this).removeClass "not_valid"  if event.keyCode is 8 or String.fromCharCode(event.which).match(/\w+|[áéíóúÁÉÍÓÚñÑ,/]+/)
            return

      return

    # if settings.interactive
    this

  $.fn.tagsInput.updateTagsField = (obj, tagslist) ->
    id = $(obj).attr("id")
    $(obj).val tagslist.join(delimiter[id])
    return

  $.fn.tagsInput.importTags = (obj, val) ->
    $(obj).val ""
    id = $(obj).attr("id")
    tags = val.split(delimiter[id])
    i = 0
    while i < tags.length
      $(obj).addTag tags[i],
        focus: false
        callback: false

      i++
    if tags_callbacks[id] and tags_callbacks[id]["onChange"]
      f = tags_callbacks[id]["onChange"]
      f.call obj, obj, tags[i]
    return

  return
) jQuery
