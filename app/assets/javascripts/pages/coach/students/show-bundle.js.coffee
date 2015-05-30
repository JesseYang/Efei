#= require "jweixin-1.0.0"
$ ->

  $(".slide-left-link").click ->
    $(this).closest(".one-course-wrapper").find(".operation-div").show('slide', {direction: 'right'}, 300)
    $("#left-filter").hide("slide")

  $(".slide-right-link").click ->
    $(this).closest(".one-course-wrapper").find(".operation-div").hide("slide", {direction: "right"}, 300)
