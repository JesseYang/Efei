$ ->
  $(".admin-nav .courses").addClass("active")

  $(".edit-lesson").click ->
    $("#editLesson").modal("show")
    $("#editLesson form").attr("action", "/admin/lessons/" + $(this).closest("tr").attr("data-id"))
    $("#editLesson #lesson_name").val($(this).closest("tr").find(".name-td").text())
    $("#editLesson #lesson_order").val($(this).closest("tr").attr("data-index"))
    $("#editLesson #lesson_homework_id").val($(this).closest("tr").attr("data-homeworkid"))
    false