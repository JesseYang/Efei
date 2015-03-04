#= require 'utility/ajax'
#= require "extensions/page_notification"
$ ->
  $(".select").click ->
    next_order = $(this).parent().find(".next").text()
    if next_order == ""
      next_order = window.next_order
    window.location.href = "/teacher/demos/#{next_order}"

  $("#demo-content-wrapper").click ->
    src = $(this).parent().find(".demo-figure").text()
    info = src.match(/^\$\$fig_(.+)\*(.+)\*(.+)\*(.+)\$\$$/)
    if info == null
      $("img").hide()
    else
      $("img").show()
      $("img").attr("src", "http://dev.image.efei.org/public/download/#{info[1]}.#{info[2]}")
      $("img").attr("width", parseInt(info[3], 10) * 1.5)
      $("img").attr("height", parseInt(info[4], 10) * 1.5)

  $(".content").click ->
    src = $(this).parent().find(".figure").text()
    info = src.match(/^\$\$fig_(.+)\*(.+)\*(.+)\*(.+)\$\$$/)
    if info == null
      $("img").hide()
    else
      $("img").show()
      $("img").attr("src", "http://dev.image.efei.org/public/download/#{info[1]}.#{info[2]}")
      $("img").attr("width", parseInt(info[3], 10) * 1.5)
      $("img").attr("height", parseInt(info[4], 10) * 1.5)
