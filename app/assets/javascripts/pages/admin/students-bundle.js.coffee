#= require "./_templates/local_course_item"
$ ->
  $(".admin-nav .students").addClass("active")

  $(".new-local-course").click ->
    id = $("#new_local_course").val()
    if id == ""
      return
    if $('*[data-id="'+id+'"]').length > 0
      return
    text = $("#new_local_course option:selected").text()
    local_course_data = 
      id: id
      name_with_number: text
    local_course_ele = $(HandlebarsTemplates["local_course_item"](local_course_data))
    $("#local-course-ul").append(local_course_ele)

  $("body").on "click", ".remove-local-course", (event) ->
    id = $(event.target).closest("li").attr("data-id")
    $(event.target).closest("li").remove()

  $("form").submit ->
    arr = [ ]
    $("#local-course-ul li").each ->
      arr.push($(this).attr("data-id"))
    $("#student_local_course_id_ary").val(arr.join(','))

  $(".local-course-select-box").change ->
    local_course_id = $(this).val()
    $.getJSON "/admin/local_courses/#{local_course_id}", (data) ->
      if data.success
        $(".city-content").text(data.info.city)
        $(".location-content").text(data.info.location)
        $(".time-content").text(data.info.time_desc)
      else
        $.page_notification "服务器出错"

  $("body").on "click", ".download-local-course-cover", (event) ->
    local_course_id = $(event.target).closest("li").attr("data-id")
    $.getJSON "/admin/students/#{window.student_id}/download_cover?local_course_id=#{local_course_id}", (data) ->
      if data.success
        window.open data.filename
      else
        $.page_notification "服务器出错"
  $(".download-local-course-cover")
