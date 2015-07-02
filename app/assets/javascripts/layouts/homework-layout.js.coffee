#= require 'utility/ajax'
#= require "../pages/teacher/nodes/_templates/sharer_list"
#= require "../pages/teacher/nodes/_templates/sharer_item"
$ ->
  guide = $.cookie(window.user_email + "homework")
  if guide != "true"
    $.cookie(window.user_email + "homework", "true", { expires: 20*365 })
    introJs().start()

  edit_title = false
  more_dropdown = false

  $(".page-guide").click ->
    introJs().start()

  $(".compose-link").click ->
    if window.editable == "true"
      go_compose("zhuanxiang")
    else
      $.page_notification("作业的所有者没有向您共享编辑权限，无法选题")

  $(".compose-link-zhuanxiang").click ->
    if window.editable == "true"
      go_compose("zhuanxiang")
    else
      $.page_notification("作业的所有者没有向您共享编辑权限，无法选题")

  $(".compose-link-zonghe").click ->
    if window.editable == "true"
      go_compose("zonghe")
    else
      $.page_notification("作业的所有者没有向您共享编辑权限，无法选题")

  go_compose = (type) ->
    $.postJSON(
      '/teacher/composes/',
      {
        homework_id: window.homework_id
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $(".compose-indicator").removeClass("hide")
          $.page_notification("前往题库")
          window.location.href = "/teacher/questions?type=#{type}"
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
    app_qr_code = $("#downloadModal #include_app_qr_code").prop("checked")
    question_qr_code = $("#downloadModal #include_question_qr_code").prop("checked")
    with_number = $("#downloadModal #with_number").prop("checked")
    with_answer = $("#downloadModal #with_answer").prop("checked")

    download_notification = $("<div />").appendTo("#downloadModal") 
    download_notification.notification
      content: "正在生成"
      delay: 0

    data_url =
      share: "/teacher/shares/#{window.share_id}/generate"
      homework: "/teacher/homeworks/#{window.homework_id}/generate"

    $.getJSON data_url[window.type] + "?with_answer=#{with_answer}&with_number=#{with_number}&app_qr_code=#{app_qr_code}&question_qr_code=#{question_qr_code}", (data) ->
      if data.success
        download_notification.notification("set_delay", 1)
        notification = $("<div />").appendTo("#downloadModal") 
        notification.notification
          content: "导出完成，正在下载"
        window.location.href = data.download_url
      else
        $.page_notification "服务器出错"
    false

  $(".more-link").click ->
    $("#more-dropdown-list").toggleClass("hide")
    more_dropdown = !$("#more-dropdown-list").hasClass("hide")
    false

  $(".copy-link").click ->
    $.page_notification("正在复制，请稍等")
    $.postJSON "/teacher/homeworks/#{window.homework_id}/copy", {
      folder_id: window.parent_id
    }, (data) ->
      if data.success
        $.page_notification "复制成功，正在跳转"
        window.location = "/teacher/homeworks/#{data.new_homework_id}"
      else
        $.page_notification "操作失败，请刷新页面重试"
    false

  $(".delete-link").click ->
    $.deleteJSON "/teacher/nodes/#{window.document_id}/delete", {}, (data) ->
      if data.success
        $.page_notification "删除成功，正在跳转"
        window.location = "/teacher/nodes?folder_id=#{window.parent_id}"
      else
        $.page_notification "操作失败，请刷新页面重试"
    false

  $("body").click ->
    if more_dropdown
      $(".ef-dropdown-menu").addClass("hide")
      more_dropdown = false
    true

  ######## Begin: share part ########
  $(".share-link").click ->
    show_share_modal()

  $("#share-input").autocomplete(
    source: "/teacher/settings/colleague_info"
  )
  $("#share-input").attr('autocomplete', 'on')

  show_share_modal = ->
    $("#shareModal").modal("show")
    $("#shareModal").attr("data-type", "Homework")
    $("#shareModal").attr("data-id", window.homework_id)
    $("#shareModal").find('.target-name').text(window.homework_name)
    $("#shareModal").find("#share-input").val("")
    $.getJSON "/teacher/homeworks/#{window.homework_id}/share_info", (data) ->
      if data.success
        sharer_list_data = { sharer: data.share_info }
        sharer_list = $(HandlebarsTemplates["sharer_list"](sharer_list_data))
        $("#sharer-list").empty()
        $("#sharer-list").append(sharer_list)
      else
        $.page_notification "服务器出错"

  $("body").on "click", "#shareModal .editable", (event) ->
    li = $(event.target).closest("li")
    cur_editable = li.attr("data-editable")
    if cur_editable == "true"
      li.attr("data-editable", "false")
      li.find(".editable").text("不可编辑")
    else
      li.attr("data-editable", "true")
      li.find(".editable").text("可编辑")

  $("body").on "click", "#shareModal .close-link", (event) ->
    li = $(event.target).closest("li")
    li.remove()

  add_colleague = (info) ->
    cur_list = [ ]
    $("#shareModal ul li").each ->
      cur_list.push($(this).attr("data-id"))
    cur_list_str = cur_list.join(',')
    $.getJSON "/teacher/settings/teacher_info?info=#{info}&list=#{cur_list_str}", (data) ->
      if data.success
        if data.id != undefined
          sharer_item = $(HandlebarsTemplates["sharer_item"](data))
          $(".sharer-list").append(sharer_item)
      else
        $.page_notification "服务器出错"

  $("#share-input").autocomplete(
    select: (event, ui) ->
      value = ui.item.value
      add_colleague(value)
      $("#share-input").val("")
      false
  )

  $("#shareModal .ok").click ->
    modal = $("#shareModal")
    id = modal.attr("data-id")
    teachers = [ ]
    $("#shareModal ul li").each ->
      teacher = {
        id: $(this).attr("data-id")
        editable: $(this).attr("data-editable")
      }
      teachers.push(teacher)
    $.putJSON '/teacher/homeworks/' + id + "/share",
      {
        teachers: teachers
      }, (data) ->
        if data.success
          modal.modal("hide")
          $.page_notification "完成共享设置"
        else
          $.page_notification "操作失败，请刷新页面重试"
        modal.modal("hide")
  ######### End: share part #########
