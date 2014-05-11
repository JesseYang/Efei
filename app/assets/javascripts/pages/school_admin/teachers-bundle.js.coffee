#= require 'utility/ajax'
$(document).ready ->

  $("#subject-select").change ->
    subject = $(this).val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject

  $("#btn-search").click ->
    search()
  $("#input-search").keydown (e) ->
    search() if e.which == 13

  search = ->
    subject = $("#subject-select").val()
    keyword = $("#input-search").val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject + "&keyword=" + keyword

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
          $('#editTeacher').modal('hide')
          $("#app-notification").notification({content: "更新成功，请刷新页面查看结果", delay: 5000})
        else
          $("#editTeacher .jesse-notification").notification({content: "更新失败，" + retval.error_msg})
    )

  $("#batch-create-btn").click ->
    $('#batchNewTeacher').modal('hide')
    $("#app-notification").notification({content: "批量处理结果会自动下载，请刷新页面查看结果", delay: 5000})
