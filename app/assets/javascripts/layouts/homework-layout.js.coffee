#= require 'utility/ajax'
$ ->
  edit_title = false


  $("#title-wrapper").hover (->
    if !edit_title
      $(this).find("#title-edit-icon").removeClass "hide"
  ), (->
    $(this).find("#title-edit-icon").addClass "hide"
  )

  $("#title-edit-icon").click ->
    $(this).closest("#title-wrapper").find("#title").addClass("hide")
    $(this).addClass("hide")
    $(this).closest("#title-wrapper").find(".title-edit").removeClass("hide")
    edit_title = true

  $(".title-edit .title-ok").click ->
    rename()

  $(".title-edit .form-control").keydown (event) ->
    code = event.which
    if code == 13
      rename()

  rename = ->
    edit_title = false
    name = $("#title-wrapper").find("input:text").val()
    $.putJSON "/teacher/nodes/#{window.homework_id}/rename", {name: name}, (data) ->
      if data.success
        $.page_notification "标题修改成功"
      else
        $.page_notification "操作失败，请刷新页面重试"
    $("#title-wrapper .title-edit").addClass("hide")
    $("#title-wrapper").find("#title").text(name)
    $("#title-wrapper").find("#title").removeClass("hide")
    $("#title-edit-icon").removeClass "hide"

  $(".title-edit .title-cancel").click ->
    edit_title = false
    $(this).closest("#title-wrapper").find("#title").removeClass("hide")
    $(this).closest(".title-edit").addClass("hide")
    $("#title-edit-icon").removeClass "hide"

  $(".remove-link").click ->
    remove()

  remove = ->
    $.deleteJSON "/teacher/nodes/#{window.homework_id}/delete", {}, (data) ->
      if data.success
        $.page_notification "删除成功，正在跳转"
        window.location = "/teacher/nodes?folder_id=#{window.parent_id}"
      else
        $.page_notification "操作失败，请刷新页面重试"
