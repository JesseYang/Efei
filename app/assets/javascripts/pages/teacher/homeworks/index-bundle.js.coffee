#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require 'ui/widgets/popup_menu'
#= require "extensions/page_notification"
#= require "./index_table"
#= require "./folder_chain"
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

  refresh_homework_table_and_folder_chain = ->
    notification = $.page_notification("正在加载", 0)
    if window.type == "folder"
      $.getJSON "/teacher/folders/#{window.folder_id}/list", (data) ->
        if data.success
          table_data = 
            type: window.type
            nodes: data.nodes
            has_content: data.nodes.length > 0
          homework_table = $(HandlebarsTemplates["pages/teacher/homeworks/index_table"](table_data))
          $("#table-wrapper").empty()
          $("#table-wrapper").append(homework_table)
        else
          $.page_notification "服务器出错"
      $.getJSON "/teacher/folders/#{window.folder_id}/chain", (data) ->
        notification.notification("set_delay", 500)
        if data.success
          chain_data = 
            type: window.type
            folder_chain: data.chain
          folder_chain = $(HandlebarsTemplates["pages/teacher/homeworks/folder_chain"](chain_data))
          $("#folder-wrapper").empty()
          $("#folder-wrapper").append(folder_chain)
        else
          $.page_notification "服务器出错"
    else if window.type == "trash"
      $.getJSON "/teacher/folders/trash", (data) ->
        if data.success
          table_data = 
            type: window.type
            nodes: data.nodes
            has_content: data.nodes.length > 0
          homework_table = $(HandlebarsTemplates["pages/teacher/homeworks/index_table"](table_data))
          $("#table-wrapper").empty()
          $("#table-wrapper").append(homework_table)
          notification.notification("set_delay", 500)
        else
          $.page_notification "服务器出错"
      folder_chain = $(HandlebarsTemplates["pages/teacher/homeworks/folder_chain"](type: window.type))
      $("#folder-wrapper").empty()
      $("#folder-wrapper").append(folder_chain)
    else if window.type == "recent"
      $.getJSON "/teacher/homeworks/recent", (data) ->
        if data.success
          table_data = 
            type: window.type
            nodes: data.nodes
            has_content: data.nodes.length > 0
          homework_table = $(HandlebarsTemplates["pages/teacher/homeworks/index_table"](table_data))
          $("#table-wrapper").empty()
          $("#table-wrapper").append(homework_table)
          notification.notification("set_delay", 500)
        else
          $.page_notification "服务器出错"
      folder_chain = $(HandlebarsTemplates["pages/teacher/homeworks/folder_chain"](type: window.type))
      $("#folder-wrapper").empty()
      $("#folder-wrapper").append(folder_chain)
    else if window.type == "search"
      $.getJSON "/teacher/folders/search?keyword=" + window.keyword, (data) ->
        if data.success
          table_data = 
            type: window.type
            nodes: data.nodes
            has_content: data.nodes.length > 0
          homework_table = $(HandlebarsTemplates["pages/teacher/homeworks/index_table"](table_data))
          $("#table-wrapper").empty()
          $("#table-wrapper").append(homework_table)
          notification.notification("set_delay", 500)
        else
          $.page_notification "服务器出错"
      folder_chain = $(HandlebarsTemplates["pages/teacher/homeworks/folder_chain"](type: window.type))
      $("#folder-wrapper").empty()
      $("#folder-wrapper").append(folder_chain)
    else if window.type == "all"
      $.getJSON "/teacher/homeworks/all", (data) ->
        if data.success
          table_data = 
            type: window.type
            nodes: data.nodes
            has_content: data.nodes.length > 0
          homework_table = $(HandlebarsTemplates["pages/teacher/homeworks/index_table"](table_data))
          $("#table-wrapper").empty()
          $("#table-wrapper").append(homework_table)
          notification.notification("set_delay", 500)
        else
          $.page_notification "服务器出错"
      folder_chain = $(HandlebarsTemplates["pages/teacher/homeworks/folder_chain"](type: window.type))
      $("#folder-wrapper").empty()
      $("#folder-wrapper").append(folder_chain)

  # get the tree stucture
  $.getJSON "/teacher/folders", (data) ->
    if data.success
      tree = $("#left-part #root-folder").folder_tree(
        content: data.tree
        root_folder_id: data.root_folder_id
        click_name_fun: redirect_folder
      )
      tree.folder_tree("select_folder", window.folder_id)
    else
      $.page_notification "服务器出错"

  # get the homework table content
  refresh_homework_table_and_folder_chain()

  $("body").on "mousedown", "#root-folder .name", (event) ->
    if event.button is 2
      name = $(event.target).text()
      folder_id = tree.folder_tree("get_folder_id_by_name_node", event.target)
      popup_menu = $("<div />").appendTo("body")
      node_type = "folder"
      page_type = "folder"
      if $(event.target).closest(".folder-list").hasClass("root")
        node_type = "root"
      popup_menu.popup_menu
        pos: [
          event.pageX
          event.pageY
        ]
        content: generate_popup_menu(folder_id, node_type, page_type)
        id: folder_id
        type: node_type
        name: name
      event.stopPropagation()

  $("body").on "mousedown", "#table-wrapper .record", (event) ->
    if event.button is 2
      type = $(event.target).closest("tr").attr("data-type")
      id = $(event.target).closest("tr").attr("data-id")
      name = $(event.target).closest("tr").attr("data-name")
      popup_menu = $("<div />").appendTo("body")
      popup_menu.popup_menu
        pos: [
          event.pageX
          event.pageY
        ]
        content: generate_popup_menu(id, type, window.type)
        id: id
        type: type
        name: name
      event.stopPropagation()

  ######## Begin: rename part ########
  $("body").on "click", ".popup-menu .rename", (event) ->
    # the rename dialog
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
    name = $(event.target).closest(".data-store").attr("data-name")
    $('.popup-menu').remove()
    $('#renameModal').modal('show')
    $("#renameModal").attr("data-type", type)
    $("#renameModal").attr("data-id", id)
    $("#renameModal .target").val(name)

  $('#renameModal').on 'shown.bs.modal', ->
    $('.target').focus()
    $('.target').select()

  $("#renameModal .ok").click ->
    type = $(this).closest("#renameModal").attr("data-type")
    if type == "folder"
      folder_id = $(this).closest("#renameModal").attr("data-id")
      name = $(this).closest("#renameModal").find(".target").val()
      $.putJSON '/teacher/folders/' + folder_id + "/rename",
        {
          name: name
        }, (data) ->
          if data.success
            tree.folder_tree("rename_folder", folder_id, name)
            refresh_homework_table_and_folder_chain()
          else
            $.page_notification "操作失败，请刷新页面重试"
          $("#renameModal").modal("hide")
    else
      # rename a doc
      homework_id = $(this).closest("#renameModal").attr("data-id")
      name = $(this).closest("#renameModal").find(".target").val()
      $.putJSON '/teacher/homeworks/' + homework_id + "/rename",
        {
          name: name
        }, (data) ->
          if data.success
            refresh_homework_table_and_folder_chain()
          else
            $.page_notification "操作失败，请刷新页面重试"
          $("#renameModal").modal("hide")
  ######## End: rename part ########

  ######## Begin: open part ########
  $("body").on "click", ".popup-menu .open", (event) ->
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
    if type == "folder"
      window.location.href = "/teacher/homeworks?folder_id=" + id
    else if type == "homework"
      $.page_notification "正在打开作业"
      window.location.href = "/teacher/homeworks/" + id
  ######## End: open part ########

  ######## Begin: stat part ########
  $("body").on "click", ".popup-menu .stat", (event) ->
    id = $(event.target).closest(".data-store").attr("data-id")
    window.location.href = "/teacher/homeworks/" + id + "/stat"
  ######## End: stat part ########

  ######## Begin: new folder part ########
  $("body").on "click", ".popup-menu .new-folder", (event) ->
    # the new folder name dialog
    folder_id = $(event.target).closest(".data-store").attr("data-id")
    $('.popup-menu').remove()
    $('#newFolderModal').modal('show')
    $("#newFolderModal").attr("data-folderid", folder_id)

  $('#newFolderModal').on 'shown.bs.modal', ->
    $('.target').focus()
    $('.target').select()

  $("#newFolderModal .ok").click ->
    parent_id = $(this).closest("#newFolderModal").attr("data-folderid")
    name = $(this).closest("#newFolderModal").find(".target").val()
    console.log parent_id
    console.log name
    $.postJSON '/teacher/folders',
      {
        parent_id: parent_id 
        name: name
      }, (data) ->
        if data.success
          new_folder = {
            id: data.folder._id
            name: name
            children: [ ]
          }
          tree.folder_tree("insert_folder", parent_id, new_folder)
          tree.folder_tree("open_folder", parent_id)
          refresh_homework_table_and_folder_chain()
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newFolderModal").modal("hide")
  ######## End: new folder part ########

  ######## Begin: new homework part ########
  $("body").on "click", ".popup-menu .new-doc", (event) ->
    folder_id = $(event.target).closest(".data-store").attr("data-id")
    $('.popup-menu').remove()
    $('#newHomeworkModal').modal('show')
    $("#newHomeworkModal #folder_id").val(folder_id)

  $("#create-btn").on "click", (event) ->
    folder_id = tree.folder_tree("get_selected_folder_id") || window.root_folder_id
    $('#newHomeworkModal').modal('show')
    $("#newHomeworkModal #folder_id").val(folder_id)
  ######## End: new homework part ########

  ######## Begin: move folder part ########
  $("body").on "click", ".popup-menu .move", (event) ->
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
    name = $(event.target).closest(".data-store").attr("data-name")
    $('.popup-menu').remove()
    $('#moveModal').modal('show')
    $("#moveModal").attr("data-type", type)
    $("#moveModal").attr("data-id", id)
    $("#moveModal").find('.target-name').text(name)
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
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
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
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
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
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
    if type == "folder"
      $.putJSON "/teacher/folders/" + id + "/recover", { }, (data) ->
        if data.success
          window.location = "/teacher/homeworks?folder_id=" + data.parent_id
        else
          $.page_notification "操作失败，请刷新页面重试"
    else
      $.getJSON "/teacher/homeworks/" + id + "/recover", { }, (data) ->
        if data.success
          window.location = "/teacher/homeworks?folder_id=" + data.parent_id
        else
          $.page_notification "操作失败，请刷新页面重试"
  ######## End: recover part ########

  ######## Begin: other redirect part ########
  $(".trash").click ->
    window.location = "/teacher/homeworks?type=trash"
  $(".recent").click ->
    window.location = "/teacher/homeworks?type=recent"
  $(".all").click ->
    window.location = "/teacher/homeworks?type=all"
  ######## End: other redirect part ########

  ######## Begin: destroy part ########
  $("body").on "click", ".popup-menu .destroy", ->
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
    if type == "folder"
      $.deleteJSON "/teacher/folders/" + id, { }, (data) ->
        if data.success
          $('.popup-menu').remove()
          refresh_homework_table_and_folder_chain()
        else
          $.page_notification "操作失败，请刷新页面重试"
    else
      $.deleteJSON "/teacher/homeworks/" + id, { }, (data) ->
        if data.success
          $('.popup-menu').remove()
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
    if type == "folder"
      $.putJSON "/teacher/folders/" + id + "/recover", { }, (data) ->
        if data.success
          window.location = "/teacher/homeworks?folder_id=" + data.parent_id
        else
          $.page_notification "操作失败，请刷新页面重试"
    else
      $.getJSON "/teacher/homeworks/" + id + "/recover", { }, (data) ->
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
