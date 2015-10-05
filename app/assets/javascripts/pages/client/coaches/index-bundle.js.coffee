#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require "layouts/client-layout"
$ ->
  $(".new").click ->
    window.location.href = "/client/coaches/new"
