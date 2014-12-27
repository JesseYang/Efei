#= require 'utility/ajax'
#= require "extensions/page_notification"
#= require "./_templates/class_item"
#= require "./_templates/students_table"
#= require "./_templates/class_select_list"
$ ->

  refresh_students_table = ->
    notification = $.page_notification("正在加载", 0)
    $.getJSON "/teacher/students/list?cid=#{window.cid}&keyword=#{window.keyword}", (data) ->
      if data.success
        $("#summary .class_name").text(data.students_summary.class_name)
        if data.students_summary.students_number == 0
          $("#summary .students_number").text("没有学生")
        else
          $("#summary .students_number").text("共#{data.students_summary.students_number}人")
        students_table = $(HandlebarsTemplates["students_table"](data.students_table))
        $("#right-part #table-wrapper").empty()
        $("#right-part #table-wrapper").append(students_table)
        notification.notification("set_delay", 500)
      else
        $.page_notification "操作失败，请刷新页面重试"


  search = (keyword) ->
    window.location.href = "/teacher/students?keyword=#{keyword}"

  $("#link-search").click (event) ->
    keyword = $("#input-search").val()
    search(keyword)

  $("#input-search").keydown (event) ->
    code = event.which
    if code == 13
      search($(this).val())

  if window.keyword == ""
    if window.cid == ""
      $(".all-students .student-link").addClass("select")
    else
      $("*[data-id=" + window.cid + "]").addClass("select")

  refresh_students_table()

  $(document).on(
    mouseenter: (event) ->
      $(event.target).closest(".class-link-wrapper").find(".remove-link").removeClass "hide"
    ,
    mouseleave: (event) ->
      $(event.target).closest(".class-link-wrapper").find(".remove-link").addClass "hide"
    , ".class-link-wrapper")

  $(document).on "click", "#class-list .remove-link", (event) ->
    li = $(event.target).closest("li")
    cid = li.find(".student-link").attr("data-id")
    $.deleteJSON "/teacher/klasses/" + cid, { }, (data) ->
      if data.success
        li.remove()
        if window.cid == cid
          window.cid = ""
          $(".all-students .student-link").addClass("select")
          refresh_students_table()
        else
          refresh_students_table()
      else
        $.page_notification "操作失败，请刷新页面重试"
    false

  $(document).on "click", ".students-table .stat-link", (event) ->
    student_id = $(event.target).closest("tr").attr("data-id")
    $.page_notification "正在打开统计数据", 0
    window.location.href = "/teacher/students/" + student_id

  $(document).on "click", ".class_select_list li", (event) ->
    $(event.target).closest("ul").find("li").removeClass("select")
    $(event.target).closest("li").addClass("select")
    $(event.target).closest(".modal").attr("data-newClassId", $(event.target).closest("li").attr("data-id"))

  $(document).on "click", ".students-table .copy-link", (event) ->
    notification = $.page_notification "正在加载", 0
    current_class_id = $(event.target).closest("tr").attr("data-classId")
    $.getJSON "/teacher/klasses?except=#{current_class_id}", (data) ->
      if data.success
        student_id = $(event.target).closest("tr").attr("data-id")
        student_name = $(event.target).closest("tr").attr("data-name")
        $("#copyStudentModal").modal("show")
        $("#copyStudentModal .target-name").text(student_name)
        $("#copyStudentModal").attr("data-id", student_id)
        $("#copyStudentModal").attr("data-classId", current_class_id)
        class_select_list = $(HandlebarsTemplates["class_select_list"](data.classes))
        $("#copyStudentModal .class_select_list").empty()
        $("#copyStudentModal .class_select_list").append(class_select_list)
        notification.notification "set_delay", 500
      else
        $.page_notification "操作失败，请刷新页面重试"

  $("#copyStudentModal .ok").click ->
    student_id = $("#copyStudentModal").attr("data-id")
    class_id = $("#copyStudentModal").attr("data-classId")
    new_class_id = $("#copyStudentModal").attr("data-newClassId")
    if new_class_id == "" || new_class_id == undefined
      modal_notification = $("<div />").appendTo($("#copyStudentModal .modal-dialog")) 
      modal_notification.notification
        delay: 1000
        content: "请选择一个分组"
      return
    $.putJSON "/teacher/students/#{student_id}/copy",
      {
        class_id: class_id
        new_class_id: new_class_id
      }, (data) ->
        if data.success
          refresh_students_table()
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#copyStudentModal").attr("data-id", "")
        $("#copyStudentModal").attr("data-classId", "")
        $("#copyStudentModal").attr("data-newClassId", "")
        $("#copyStudentModal").modal("hide")

  $(document).on "click", ".students-table .move-link", (event) ->
    notification = $.page_notification "正在加载", 0
    current_class_id = $(event.target).closest("tr").attr("data-classId")
    $.getJSON "/teacher/klasses?except=#{current_class_id}", (data) ->
      if data.success
        student_id = $(event.target).closest("tr").attr("data-id")
        student_name = $(event.target).closest("tr").attr("data-name")
        $("#moveStudentModal").modal("show")
        $("#moveStudentModal .target-name").text(student_name)
        $("#moveStudentModal").attr("data-id", student_id)
        $("#moveStudentModal").attr("data-classId", current_class_id)
        class_select_list = $(HandlebarsTemplates["class_select_list"](data.classes))
        $("#moveStudentModal .class_select_list").empty()
        $("#moveStudentModal .class_select_list").append(class_select_list)
        notification.notification "set_delay", 500
      else
        $.page_notification "操作失败，请刷新页面重试"

  $("#moveStudentModal .ok").click ->
    student_id = $("#moveStudentModal").attr("data-id")
    class_id = $("#moveStudentModal").attr("data-classId")
    new_class_id = $("#moveStudentModal").attr("data-newClassId")
    $.putJSON "/teacher/students/#{student_id}/move",
      {
        class_id: class_id
        new_class_id: new_class_id
      }, (data) ->
        if data.success
          refresh_students_table()
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#moveStudentModal").attr("data-id", undefined)
        $("#moveStudentModal").attr("data-classId", undefined)
        $("#moveStudentModal").attr("data-newClassId", undefined)
        $("#moveStudentModal").modal("hide")

  $(document).on "click", ".students-table .remove-link", (event) ->
    student_id = $(event.target).closest("tr").attr("data-id")
    class_id = $(event.target).closest("tr").attr("data-classId")
    $.deleteJSON "/teacher/students/#{student_id}",
      {
        class_id: class_id
      }, (data) ->
        if data.success
          refresh_students_table()
        else
          $.page_notification "操作失败，请刷新页面重试"

  $(document).on "click", ".class-link-wrapper", (event) ->
    cid = $(event.target).closest(".class-link-wrapper").find(".student-link").attr("data-id")
    $.page_notification "正在跳转"
    window.location.href = "/teacher/students?cid=#{cid}"

  $(".new-class").click ->
    $("#newClassModal").modal("show")

  $("#newClassModal .ok").click ->
    name = $("#newClassModal .target").val()
    create_class(name)

  $("#newClassModal .target").keydown (event) ->
    code = event.which
    if code == 13
      create_class($(this).val())

  create_class = (name) ->
    $.postJSON '/teacher/klasses',
      {
        name: name
      }, (data) ->
        if data.success
          class_data =
            id: data.klass.id
            name: data.klass.name
          new_class = $(HandlebarsTemplates["class_item"](class_data))
          last_class = $("#class-list").find(".student-link:last").closest("li")
          last_class.before(new_class)
          $.page_notification "分组创建成功"
          console.log data.klass
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newClassModal").modal("hide")