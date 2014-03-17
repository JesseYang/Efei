$ ->

(($, window, document) ->
  $.validateEmail = (email) ->
    if email == ""
      return false
    emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
    if emailReg.test(email)
      true
    else
      false
) jQuery, window, document
