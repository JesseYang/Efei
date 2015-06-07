$ ->

  $(".filter").click ->
    $("#left-filter").toggle()

  $(".turnoff").click ->
    $("#left-filter").toggle()

  $(".lesson-link").click ->
    target = $(this).parent().find(".lesson-detail")
    if target.css("display") == "none"
      $(".lesson-detail").hide()
      $(this).parent().find(".lesson-detail").toggle()
    else
      $(".lesson-detail").hide()

  $(".lesson-link").dotdotdot()

