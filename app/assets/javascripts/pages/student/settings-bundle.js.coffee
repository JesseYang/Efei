#= require 'utility/ajax'
$(document).ready ->
  if window.type == "update_password"
    $('#myTab a[href="#password"]').tab('show')
  if window.type == "teacher_info"
    $('#myTab a[href="#teacher"]').tab('show')

  $(".remove-teacher").click ->
    teacher_id = $(this).data('teacher-id')
    $this = $(this)
    $.deleteJSON(
      '/student/teachers/' + teacher_id,
      { },
      (retval) ->
        $this.closest(".container").remove()
    )

  $(".add-teacher").click ->
    teacher_id = $(this).closest(".container").find(".teacher-select").val()
    console.log teacher_id
    $.postJSON(
      '/student/teachers/',
      {
        id: teacher_id
      },
      (retval) ->
        window.location = "/student/settings/#{window.student_id}?type=teacher_info"
    )
