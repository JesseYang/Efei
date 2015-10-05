#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require "layouts/client-layout"
$ ->

  $.getJSON "/client/coaches/list", (data) ->
    if data.success
      $("#new_coach").autocomplete {
        source: data.data
      }
    else
      $.page_notification "服务器出错"
