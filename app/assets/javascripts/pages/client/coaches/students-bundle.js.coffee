#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require "layouts/client-layout"
$ ->

  $.getJSON "/client/students/list", (data) ->
    if data.success
      $("#new_student").autocomplete {
        source: data.data
      }
    else
      $.page_notification "服务器出错"
