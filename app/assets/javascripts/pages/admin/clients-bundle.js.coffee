#= require 'utility/ajax'
$ ->
  $(".admin-nav .clients").addClass("active")

  $(".client-search-btn").click ->
    search()

  $("#input-search").keydown (event) ->
    code = event.which
    if code == 13
      search()

  search = ->
    keyword = $("#input-search").val()
    window.location.href = "/admin/clients?keyword=" + keyword

