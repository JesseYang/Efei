$ ->
  $(".filter").click ->
    $("#left-filter").toggle("slide")

  $(".turnoff").click ->
    $("#left-filter").toggle("slide")

  $("#left-filter li").click ->
    $("#left-filter").toggle("slide")