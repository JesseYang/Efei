$ ->
  $("img.lazy").jail()
  $(".exercise-title-wrapper").click ->
    if $(this).find(".ic-expand").hasClass("hide")
      $(this).next().slideUp()
      $(this).find(".ic-contract").addClass("hide")
      $(this).find(".ic-expand").removeClass("hide")
    else
      $(this).next().slideDown()
      $(this).find(".ic-expand").addClass("hide")
      $(this).find(".ic-contract").removeClass("hide")

  $(".snapshot-summary").each ->
    if $(this).find("li").length == 0
      $(this).addClass("hide")

