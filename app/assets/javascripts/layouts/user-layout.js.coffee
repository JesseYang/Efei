$ ->
  if window.controller == "user/notes"
    $("#app-user-navbar .nav .notes").addClass("active")
  if window.controller == "user/papers"
    $("#app-user-navbar .nav .papers").addClass("active")
