$ ->
  $(".admin-nav .local_courses").addClass("active")

  $(".btn-filter").click ->
    subject = $("#course_subject").val()
    type = $("#course_type").val()
    window.location.href = "/admin/local_courses?subject=#{subject}&type=#{type}"