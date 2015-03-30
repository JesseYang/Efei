$ ->
  if window.type == "update_password"
    $('#myTab a[href="#profile"]').tab('show')
  $(".page-guide").closest("li").hide()
