#= require 'utility/ajax'
#= require "extensions/page_notification"

$ ->
  $(".thumbnail:first").addClass("selected")

  size_calc = ->
    min_padding = 20
    min_padding = 20
    region_width = $("#right-part").width()
    region_height = $("#right-part").height()
    image_width = 720
    image_height = 540
    if region_width > image_width + 2 * min_padding && region_height > image_height + 2 * min_padding
      $("#current-image").css("margin-left", (region_width - image_width) / 2)
      $("#current-image").css("margin-right", (region_width - image_width) / 2)
      $("#current-image").css("margin-top", (region_height - image_height) / 2)
      $("#current-image").css("margin-bottom", (region_height - image_height) / 2)
    else if region_width > image_width + 2 * min_padding && region_height < image_height + 2 * min_padding
      image_height = region_height - 2 * min_padding
      $("#current-image").css("height", image_height)
      $("#current-image img").css("height", image_height)
      $("#current-image").css("margin-top", min_padding)
      $("#current-image").css("margin-bottom", min_padding)
      image_width = $("#current-image img").width()
      $("#current-image").css("margin-left", (region_width - image_width) / 2)
      $("#current-image").css("margin-right", (region_height - image_height) / 2)

  size_calc()

  $(window).resize ->
    size_calc()



  $(".thumbnail").click ->
    if $(this).hasClass("selected")
      return
    $(".thumbnail").removeClass("selected")
    $(this).addClass("selected")
    page_id = $(this).closest(".thumbnail-wrapper").attr("data-id")
    $("#current-image img").attr("src", "http://dev.image.efei.org/public/slides/" + page_id + ".jpg")
    console.log page_id