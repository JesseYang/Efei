#= require 'utility/ajax'
#= require "./_templates/teachers_table"
#= require "./_templates/classes_list"

$ ->

  search_new_teachers = ->
    keyword = $("#input-search").val()
    $.getJSON "/student/teachers/list?keyword=#{keyword}", (data) ->
      if data.success
        teachers_data = 
          teachers: data.teachers
        teachers_table = $(HandlebarsTemplates["teachers_table"](teachers_data))
        $("#new-teachers-table-wrapper").empty()
        $("#new-teachers-table-wrapper").append(teachers_table)
      else
        $.page_notification "服务器出错"


  $("#link-search").click ->
    search_new_teachers()

  $("#input-search").keydown (event) ->
    code = event.which
    if code == 13
      search_new_teachers()

  $("body").on "click", ".add-teacher-link", (event) ->
    t_id = $(event.target).closest("tr").attr("data-teacher-id")
    $.getJSON "/student/teachers/#{t_id}/list_classes", (data) ->
      if data.success
        if data.classes.length == 1
          $.putJSON "/student/teachers/#{t_id}/add_teacher?class_id=#{data.classes[0].id}", { }, (data) ->
            if data.success
              window.location.href = "/student/teachers/list?scope=1&flash=添加教师成功"
            else
              $.page_notification "操作失败，请刷新页面重试"
        else
          $('#selectClassModal').modal('show')
          classes_data =
            classes: data.classes
          classes_list = $(HandlebarsTemplates["classes_list"](classes_data))
          $("#classes-list-wrapper").empty()
          $("#classes-list-wrapper").append(classes_list)
      else
        $.page_notification "服务器出错"

  $("body").on "click", ".select-class-link", (event) ->
    c_id = $(event.target).closest("li").attr("data-teacher-id")
