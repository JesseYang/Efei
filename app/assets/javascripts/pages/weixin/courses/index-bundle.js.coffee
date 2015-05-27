$ ->
  $(".filter").click ->
    $("#left-filter").toggle("slide")

  $(".turnoff").click ->
    $("#left-filter").toggle("slide")

  $("#left-filter li").click ->
    $("#left-filter").toggle("slide")

  $(".slide-left-link").click ->
    $(this).closest(".one-course-wrapper").find(".operation-div").show('slide', {direction: 'right'}, 300);

  $(".slide-right-link").click ->
    $(this).closest(".one-course-wrapper").find(".operation-div").hide("slide", {direction: "right"}, 300)
