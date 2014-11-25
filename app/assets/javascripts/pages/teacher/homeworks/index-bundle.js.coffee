#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require 'ui/widgets/popup_menu'
#= require "extensions/page_notification"
#= require "./_templates/index_table"
#= require "./_templates/folder_chain"
$ ->
  Handlebars.registerHelper "ifCond", (v1, v2, options) ->
    return options.fn(this)  if v1 is v2
    options.inverse this

  # forbit the default right-click popup menu
  $("body").bind "contextmenu", ->
    false

  tree = null
  move_tree = null
  homework_table = null
  nodes = [ ]
  popup_menu = null

  refresh_homework_table_and_folder_chain = ->
    notification = $.page_notification("正在加载", 0)
    if window.type == "folder"
      $.getJSON "/teacher/folders/#{window.folder_id}/chain", (data) ->
        if data.success
          chain_data = 
            type: window.type
            folder_chain: data.chain
          folder_chain = $(HandlebarsTemplates["folder_chain"](chain_data))
          $("#folder-wrapper").empty()
          $("#folder-wrapper").append(folder_chain)
        else
          $.page_notification "服务器出错"
    else
      folder_chain = $(HandlebarsTemplates["folder_chain"](type: window.type))
      $("#folder-wrapper").empty()
      $("#folder-wrapper").append(folder_chain)

    data_url =
      folder: "/teacher/folders/#{window.folder_id}/list"
      trash: "/teacher/folders/trash"
      recent: "/teacher/homeworks/recent"
      search: "/teacher/folders/search?keyword=" + window.keyword
      all: "/teacher/homeworks/all"
    $.getJSON data_url[window.type], (data) ->
      if data.success
        table_data = 
          type: window.type
          nodes: data.nodes
          has_content: data.nodes.length > 0
        homework_table = $(HandlebarsTemplates["index_table"](table_data))
        $("#table-wrapper").empty()
        $("#table-wrapper").append(homework_table)
        notification.notification("set_delay", 500)
      else
        $.page_notification "服务器出错"

  # get the tree stucture
  $.getJSON "/teacher/folders", (data) ->
    if data.success
      tree = $("#left-part #root-folder").folder_tree(
        content: data.tree
        root_folder_id: data.root_folder_id
        click_name_fun: redirect_folder
      )
      tree.folder_tree("select_folder", window.folder_id) if window.folder_id != ""
    else
      $.page_notification "服务器出错"

  # get the homework table content
  refresh_homework_table_and_folder_chain()

  $("body").on "mousedown", "#root-folder .name", (event) ->
    if event.button is 2
      node_type = "folder"
      id = tree.folder_tree("get_folder_id_by_name_node", event.target)
      name = $(event.target).text()
      page_type = "folder"
      popup_menu = $("<div />").appendTo("body")
      if $(event.target).closest(".folder-list").hasClass("root")
        node_type = "root"
      popup_menu.popup_menu
        pos: [
          event.pageX
          event.pageY
        ]
        content: generate_popup_menu(id, node_type, page_type)
        id: id
        type: node_type
        name: name
      event.stopPropagation()

  $("body").on "mousedown", "#table-wrapper .record", (event) ->
    if event.button is 2
      node_type = $(event.target).closest("tr").attr("data-type")
      id = $(event.target).closest("tr").attr("data-id")
      name = $(event.target).closest("tr").attr("data-name")
      popup_menu = $("<div />").appendTo("body")
      popup_menu.popup_menu
        pos: [
          event.pageX
          event.pageY
        ]
        content: generate_popup_menu(id, node_type, window.type)
        id: id
        type: node_type
        name: name
      event.stopPropagation()

  ######## Begin: rename part ########
  $("body").on "click", ".popup-menu .rename", (event) ->
    data = popup_menu.popup_menu("option")
    $('.popup-menu').remove()
    $('#renameModal').modal('show')
    $("#renameModal").attr("data-type", data.type)
    $("#renameModal").attr("data-id", data.id)
    $("#renameModal .target").val(data.name)

  $('#renameModal').on 'shown.bs.modal', ->
    $('.target').focus()
    $('.target').select()

  $("#renameModal .ok").click ->
    type = $(this).closest("#renameModal").attr("data-type")
    id = $(this).closest("#renameModal").attr("data-id")
    name = $(this).closest("#renameModal").find(".target").val()
    data_url = 
      folder: "/teacher/folders/#{id}/rename"
      homework: "/teacher/homeworks/#{id}/rename"
    $.putJSON data_url[type], {name: name}, (data) ->
      if data.success
        tree.folder_tree("rename_folder", id, name) if type == "folder"
        refresh_homework_table_and_folder_chain()
      else
        $.page_notification "操作失败，请刷新页面重试"
      $("#renameModal").modal("hide")
  ######## End: rename part ########

  ######## Begin: open part ########
  $("body").on "click", ".popup-menu .open", (event) ->
    data = popup_menu.popup_menu("option")
    if data.type == "folder"
      window.location.href = "/teacher/homeworks?folder_id=" + data.id
    else if data.type == "homework"
      $.page_notification "正在打开作业"
      window.location.href = "/teacher/homeworks/" + data.id
  ######## End: open part ########

  ######## Begin: stat part ########
  $("body").on "click", ".popup-menu .stat", (event) ->
    data = popup_menu.popup_menu("option")
    window.location.href = "/teacher/homeworks/" + data.id + "/stat"
  ######## End: stat part ########

  ######## Begin: new folder part ########
  $("body").on "click", ".popup-menu .new-folder", (event) ->
    # the new folder name dialog
    data = popup_menu.popup_menu("option")
    $('.popup-menu').remove()
    $('#newFolderModal').modal('show')
    $("#newFolderModal").attr("data-folderid", data.id)

  $('#newFolderModal').on 'shown.bs.modal', ->
    $('.target').focus()
    $('.target').select()

  $("#newFolderModal .ok").click ->
    parent_id = $(this).closest("#newFolderModal").attr("data-folderid")
    name = $(this).closest("#newFolderModal").find(".target").val()
    $.postJSON '/teacher/folders',
      {
        parent_id: parent_id 
        name: name
      }, (data) ->
        if data.success
          new_folder =
            id: data.folder._id
            name: name
            children: [ ]
          tree.folder_tree("insert_folder", parent_id, new_folder)
          tree.folder_tree("open_folder", parent_id)
          refresh_homework_table_and_folder_chain()
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newFolderModal").modal("hide")
  ######## End: new folder part ########

  ######## Begin: new homework part ########
  $("body").on "click", ".popup-menu .new-doc", (event) ->
    data = popup_menu.popup_menu("option")
    $('.popup-menu').remove()
    $('#newHomeworkModal').modal('show')
    $("#newHomeworkModal #folder_id").val(data.id)

  $("#create-btn").on "click", (event) ->
    folder_id = tree.folder_tree("get_selected_folder_id") || window.root_folder_id
    $('#newHomeworkModal').modal('show')
    $("#newHomeworkModal #folder_id").val(folder_id)
  ######## End: new homework part ########

  ######## Begin: move folder part ########
  $("body").on "click", ".popup-menu .move", (event) ->
    data = popup_menu.popup_menu("option")
    $('.popup-menu').remove()
    $('#moveModal').modal('show')
    $("#moveModal").attr("data-type", data.type)
    $("#moveModal").attr("data-id", data.id)
    $("#moveModal").find('.target-name').text(data.name)
    $.getJSON "/teacher/folders", (data) ->
      if data.success
        move_tree = $("#moveModal #move-folder").folder_tree(
          content: data.tree
          root_folder_id: data.root_folder_id
          click_name_fun: (folder_id) ->
            move_tree.folder_tree("select_folder", folder_id)
        )
        move_tree.folder_tree("select_folder", data.root_folder_id)
        move_tree.folder_tree("open_folder", data.root_folder_id)
      else
        $.page_notification "服务器出错"

  $('#moveModal .ok').click ->
    type = $(this).closest("#moveModal").attr("data-type")
    if type == "folder"
      folder_id = $(this).closest("#moveModal").attr("data-id")
      des_folder_id = move_tree.folder_tree("get_selected_folder_id")
      $.putJSON '/teacher/folders/' + folder_id + "/move",
        {
          des_folder_id: des_folder_id
        }, (data) ->
          if data.success
            tree.folder_tree("move_folder", folder_id, des_folder_id)
            tree.folder_tree("open_folder", des_folder_id)
            refresh_homework_table_and_folder_chain()
          else
            $.page_notification "操作失败，请刷新页面重试"
          $("#moveModal").modal("hide")
    else
      # move a document
      homework_id = $(this).closest("#moveModal").attr("data-id")
      des_folder_id = move_tree.folder_tree("get_selected_folder_id")
      $.putJSON '/teacher/homeworks/' + homework_id + "/move",
        {
          folder_id: des_folder_id
        }, (data) ->
          if data.success
            refresh_homework_table_and_folder_chain()
          else
            $.page_notification "操作失败，请刷新页面重试"
          $("#moveModal").modal("hide")
  ######## End: move folder part ########

  ######## Begin: delete part ########
  $("body").on "click", ".popup-menu .delete", (event) ->
    type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    if type == "folder"
      $.deleteJSON "/teacher/folders/" + id + "/delete", {}, (data) ->
        if data.success
          parent_id = tree.folder_tree("get_parent_id", id)
          tree.folder_tree("remove_folder", id)
          $(".popup-menu").remove()
          if window.folder_id == id
            window.location.href = "/teacher/homeworks?folder_id=" + parent_id
          else
            refresh_homework_table_and_folder_chain()
        else
          $.page_notification "操作失败，请刷新页面重试"
    else if type == "homework"
      $.deleteJSON "/teacher/homeworks/" + id + "/delete", {}, (data) ->
        if data.success
          $(".popup-menu").remove()
          refresh_homework_table_and_folder_chain()
        else
          $.page_notification "操作失败，请刷新页面重试"
  ######## End: delete part ########

  ######## Begin: redirect part ########
  redirect_folder = (folder_id) ->
    window.location = '/teacher/homeworks?folder_id=' + folder_id
  ######## End: redirect part ########

  ######## Begin: open parent part ########
  $("body").on "click", ".popup-menu .open-parent", (event) ->
    type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    if type == "folder"
      parent_id = tree.folder_tree("get_parent_id", id)
      window.location = "/teacher/homeworks?folder_id=" + parent_id
    else
      $.getJSON "/teacher/homeworks/" + id + "/get_folder_id", (data) ->
        if data.success
          window.location = "/teacher/homeworks?folder_id=" + data.folder_id
        else
          $.page_notification "操作失败，请刷新页面重试"
  ######## End: open parent part ########

  ######## Begin: recover part ########
  $("body").on "click", ".popup-menu .recover", (event) ->
    type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    $.putJSON "/teacher/#{type}s/#{id}/recover", { }, (data) ->
      if data.success
        window.location = "/teacher/homeworks?folder_id=" + data.parent_id
      else
        $.page_notification "操作失败，请刷新页面重试"
  ######## End: recover part ########

  ######## Begin: other redirect part ########
  $.each ["trash", "recent", "all"], (i, v) ->
    $(".#{v}").click ->
      window.location = "/teacher/homeworks?type=#{v}"
  ######## End: other redirect part ########

  ######## Begin: destroy part ########
  $("body").on "click", ".popup-menu .destroy", ->
    type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    data_url =
      folder: "/teacher/folders/#{id}"
      homework: "/teacher/homeworks/#{id}"
    $.deleteJSON data_url[type], { }, (data) ->
      if data.success
        $(".popup-menu").remove()
        refresh_homework_table_and_folder_chain()
      else
      $.page_notification "操作失败，请刷新页面重试"
  ######## End: destroy part ########

  ######## Begin: search part ########
  $("#btn-search").click ->
    keyword = $("#input-search").val()
    window.location = "/teacher/homeworks?type=search&keyword=" + keyword
  ######## End: destroy part ########


  $("body").on "click", "*[data-pagetype=trash] a", (event) ->
    $("#recoverModal").modal('show')
    type = $(event.target).closest("tr").attr("data-type")
    id = $(event.target).closest("tr").attr("data-id")
    $("#recoverModal").attr("data-type", type)
    $("#recoverModal").attr("data-id", id)
    event.preventDefault()

  $("#recoverModal .ok").click ->
    type = $("#recoverModal").attr("data-type")
    id = $("#recoverModal").attr("data-id")
    data_url = 
      folder: "/teacher/folders/#{id}/recover"
      homework: "/teacher/homeworks/#{id}/recover"
    $.putJSON data_url[type], { }, (data) ->
      if data.success
        window.location = "/teacher/homeworks?folder_id=" + data.parent_id
      else
        $.page_notification "操作失败，请刷新页面重试"

  generate_popup_menu = (id, folder_type, page_type) ->
    if page_type == "trash"
      return [
        {
          text: "还原"
          class: "recover"
        }
        {
          text: "彻底删除"
          class: "destroy"
        }
      ]
    if folder_type == "root"
      return [
        {
          text: "新建文件夹"
          class: "new-folder"
        }
        {
          text: "新建文件"
          class: "new-doc"
        }
      ]
    if folder_type == "folder"
      return [
        {
          text: "新建文件夹"
          class: "new-folder"
        }
        {
          text: "新建文件"
          class: "new-doc"
        }
        {
          hr: true
        }
        {
          text: "重命名"
          class: "rename"
        }
        {
          text: "移动"
          class: "move"
        }
        {
          text: "删除"
          class: "delete"
        }
      ] if page_type == "folder"
      return [
        {
          text: "新建文件夹"
          class: "new-folder"
        }
        {
          text: "新建文件"
          class: "new-doc"
        }
        {
          hr: true
        }
        {
          text: "打开所在文件夹"
          class: "open-parent"
        }
        {
          text: "重命名"
          class: "rename"
        }
        {
          text: "移动"
          class: "move"
        }
        {
          text: "删除"
          class: "delete"
        }
      ] if page_type == "recent" || page_type == "search" || page_type == "all"
    if folder_type == "homework"
      return [
        {
          text: "打开"
          class: "open"
        }
        {
          text: "统计"
          class: "stat"
        }
        {
          hr: true
        }
        {
          text: "重命名"
          class: "rename"
        }
        {
          text: "移动"
          class: "move"
        }
        {
          text: "删除"
          class: "delete"
        }
      ] if page_type == "folder"
      return [
        {
          text: "打开"
          class: "open"
        }
        {
          text: "统计"
          class: "stat"
        }
        {
          hr: true
        }
        {
          text: "打开所在文件夹"
          class: "open-parent"
        }
        {
          text: "重命名"
          class: "rename"
        }
        {
          text: "移动"
          class: "move"
        }
        {
          text: "删除"
          class: "delete"
        }
      ] if page_type == "recent" || page_type == "search" || page_type == "all"


