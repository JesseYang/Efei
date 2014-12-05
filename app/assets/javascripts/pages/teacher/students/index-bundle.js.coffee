#= require 'utility/ajax'
#= require "extensions/page_notification"
#= require "./_templates/class_item"
$ ->
  if window.cid == ""
    $(".all-students .student-link").addClass("select")
  else
    $("*[data-id=" + window.cid + "]").addClass("select")

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
            id: data.klass.$oid
            name: data.klass.name
          new_class = $(HandlebarsTemplates["class_item"](class_data))
          last_class = $("#class-list").find(".student-link:last")
          last_class.before(new_class)
          $.page_notification "分组创建成功"
          console.log data.klass
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newClassModal").modal("hide")