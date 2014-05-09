#= require 'utility/ajax'
$(document).ready ->

  $(".edit-teacher").click ->
    $("#editTeacher #teacher_id").val($(this).data("id"))
    $("#editTeacher #teacher_name").val($(this).data("name"))
    $("#editTeacher #teacher_email").val($(this).data("email"))
    $("#editTeacher #teacher_subject").val($(this).data("subject"))

  $("#update-btn").click ->
    $this = $(this)
    $this.text("正在更新...")
    $this.attr("disabled", true)
    $.putJSON(
      '/school_admin/teachers/' + $("#editTeacher #teacher_id").val(),
      {
        name: $("#editTeacher #teacher_name").val(),
        email: $("#editTeacher #teacher_email").val(),
        subject: $("#editTeacher #teacher_subject").val(),
        password: $("#editTeacher #teacher_password").val(),
      },
      (retval) ->
        $this.attr("disabled", false)
        $this.text("更新")
        if retval.success
          $("#editTeacher #teacher_password").val("")
          $("#editTeacher .jesse-notification").notification({content: "更新成功"})
        else
          $("#editTeacher .jesse-notification").notification({content: "更新失败，" + retval.error_msg})
    )
