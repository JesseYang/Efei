#= require 'utility/ajax'
$ ->
  edit_title = false

  $(".compose-link").click ->
    $.postJSON(
      '/teacher/composes/',
      {
        homework_id: window.homework_id
      },
      (retval) ->
        console.log retval
        if !retval.success
          $.page_notification(retval.message)
        else
          $(".compose-indicator").removeClass("hide")
          $.page_notification("前往题库")
          window.location.href = "/teacher/questions?type=zhuanxiang"
    )

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

  remove = ->
    $.deleteJSON "/teacher/nodes/#{window.homework_id}/delete", {}, (data) ->
      if data.success
        $.page_notification "删除成功，正在跳转"
        window.location = "/teacher/nodes?folder_id=#{window.parent_id}"
      else
        $.page_notification "操作失败，请刷新页面重试"

  $(".remove-link").click ->
    remove()

  download_notification = undefined

  $(".download-link").click ->
    $("#downloadModal").modal("show")

  $("#downloadModal form").submit ->
    # doc_type = $("#downloadModal input:radio[name='doc_type']:checked").val()
    qr_code = $("#downloadModal input:radio[name='qr_code']:checked").val()
    download_notification = $("<div />").appendTo("#downloadModal") 
    download_notification.notification
      content: "正在生成"
      delay: 0
    $.getJSON "/teacher/homeworks/#{window.homework_id}/generate?qr_code=#{qr_code}", (data) ->
      if data.success
        download_notification.notification("set_delay", 1)
        notification = $("<div />").appendTo("#downloadModal") 
        notification.notification
          content: "导出完成，正在下载"
        window.location.href = data.download_url
      else
        $.page_notification "服务器出错"

    false
