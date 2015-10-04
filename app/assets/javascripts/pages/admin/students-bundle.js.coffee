#= require 'utility/ajax'
$ ->
  $(".admin-nav .students").addClass("active")

  $(".student-search-btn").click ->
    search()

  $("#input-search").keydown (event) ->
    code = event.which
    if code == 13
      search()

  search = ->
    keyword = $("#input-search").val()
    window.location.href = "/admin/students?keyword=" + keyword
