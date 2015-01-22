$ ->
  dropdown = false

  if window.show_compose == "true"
    $(".compose-indicator").removeClass("hide")

  $(".compose-indicator").click ->
    window.location.href = "/teacher/composes"

  if window.controller == "teacher/homeworks"
    $("#app-user-navbar .nav .homeworks").addClass("active")

  $("#teacher-navbar .ef-dropdown-toggle").click (event) ->
    if $(this).hasClass("dropdown-active")
      $(this).removeClass("dropdown-active")
      $("#teacher-navbar .ef-dropdown-menu").addClass("hide")
      dropdown = false
    else
      $(this).addClass("dropdown-active")
      $("#teacher-navbar .ef-dropdown-menu").removeClass("hide")
      dropdown = true
    false

  $("body").click ->
    if dropdown
      $(".ef-dropdown-toggle").removeClass("dropdown-active")
      $(".ef-dropdown-menu").addClass("hide")
      dropdown = false
    true
