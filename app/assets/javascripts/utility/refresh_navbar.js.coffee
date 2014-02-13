$ ->

(($, window, document) ->
  $.refresh_navbar = (email) ->
    $("#app-user-navbar .navbar-right .dropdown-toggle span").html(email)
    $("#app-user-navbar .navbar-right .dropdown-menu").html("<li><a data-method='delete' href='/users/sign_out' rel='nofollow'>退出</a></li>")
) jQuery, window, document
