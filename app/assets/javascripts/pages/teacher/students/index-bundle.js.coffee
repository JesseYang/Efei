#= require 'utility/ajax'
#= require "extensions/page_notification"
#= require "./_templates/class_item"
$ ->

  if window.cid == ""
    $(".all-students .student-link").addClass("select")
  else
    $("*[data-id=" + window.cid + "]").addClass("select")

  $(document).on(
    mouseenter: (event) ->
      $(event.target).closest(".class-link-wrapper").find(".remove-link").removeClass "hide"
    ,
    mouseleave: (event) ->
      $(event.target).closest(".class-link-wrapper").find(".remove-link").addClass "hide"
  , ".class-link-wrapper")

  $(document).on "click", ".remove-link", (event) ->
    li = $(event.target).closest("li")
    cid = li.find(".student-link").attr("data-id")
    $.deleteJSON "/teacher/klasses/" + cid, { }, (data) ->
      if data.success
        li.remove()
        $.page_notification "删除成功，正在加载", 0
        if window.cid == cid
          window.href = "/teacher/students"
        else
          window.href = "/teacher/students?cid=" + window.cid
      else
        $.page_notification "操作失败，请刷新页面重试"

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
          last_class = $("#class-list").find(".student-link:last").closest("li")
          last_class.before(new_class)
          $.page_notification "分组创建成功"
          console.log data.klass
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newClassModal").modal("hide")