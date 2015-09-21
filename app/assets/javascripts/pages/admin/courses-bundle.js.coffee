$ ->
  $(".admin-nav .courses").addClass("active")

  $(".edit-lesson").click ->
    $("#editLesson").modal("show")
    $("#editLesson form").attr("action", "/admin/lessons/" + $(this).closest("tr").attr("data-id"))
    $("#editLesson #lesson_name").val($(this).closest("tr").find(".name-td").text())
    $("#editLesson #lesson_order").val($(this).closest("tr").attr("data-index"))
    $("#editLesson #lesson_pre_test_id").val($(this).closest("tr").attr("data-pretestid"))
    $("#editLesson #lesson_exercise_id").val($(this).closest("tr").attr("data-exerciseid"))
    $("#editLesson #lesson_post_test_id").val($(this).closest("tr").attr("data-posttestid"))
    false

  $(".btn-filter").click ->
    subject = $("#course_subject").val()
    type = $("#course_type").val()
    window.location.href = "/admin/courses?subject=#{subject}&type=#{type}"

  $(".btn-edit").click ->
    tr = $(this).closest("tr")
    $("#editCourse form").attr("action", "/admin/courses/#{tr.attr("data-id")}")
    $("#editCourse .course-name").text("编辑课程：" + tr.attr("data-name"))
    $("#editCourse #course_teacher_id").val(tr.attr("data-teacher-id"))
    $("#editCourse #course_subject").val(tr.attr("data-subject"))
    $("#editCourse #course_type").val(tr.attr("data-type"))
    $("#editCourse #course_name").val(tr.attr("data-name"))
    $("#editCourse #course_start_at").val(tr.attr("data-start-at"))
    $("#editCourse #course_end_at").val(tr.attr("data-end-at"))
    $("#editCourse #course_grade").val(tr.attr("data-grade"))
    $("#editCourse #course_desc").val(tr.attr("data-desc"))
    $("#editCourse #course_suggestion").val(tr.attr("data-suggestion"))
    $("#editCourse").modal("show")

  $("#course_selector").change ->
    val = $(this).val()
    $.getJSON "/admin/lessons/list?course_id=#{val}", (data) ->
      if data.success
        $("#lesson_selector").empty()
        $.each data.data, (k, v) ->
          $('#lesson_selector')
            .append($("<option></option>")
            .attr("value",v)
            .text(k)); 
      else
        $.page_notification "服务器出错"

  $("#lesson_selector").change ->
    val = $(this).val()
    $.getJSON "/admin/videos/list?lesson_id=#{val}", (data) ->
      if data.success
        $("#existing_video_content").empty()
        $.each data.data, (k, v) ->
          $('#existing_video_content')
            .append($("<option></option>")
            .attr("value",v)
            .text(k)); 
      else
        $.page_notification "服务器出错"
