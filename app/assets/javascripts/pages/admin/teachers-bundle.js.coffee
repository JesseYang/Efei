$ ->
  $(".admin-nav .teachers").addClass("active")

  $(".edit-teacher").click ->
    $("#editTeacher").modal("show")
    $("#editTeacher form").attr("action", "/admin/teachers/" + $(this).closest("tr").attr("data-id"))
    $("#editTeacher #teacher_name").val($(this).closest("tr").find(".name-td").text())
    $("#editTeacher #teacher_desc").val($(this).closest("tr").find(".desc-td").text())

