#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require 'ui/widgets/popup_menu'
#= require "extensions/page_notification"
#= require "./_templates/index_table"
#= require "./_templates/folder_chain"
$ ->


  # forbit the default right-click popup menu
  $("html").bind "contextmenu", ->
    false
  $("html").click ->
    popup_menu.remove() if popup_menu != null
  $("html").mousedown (event) ->
    if event.button == 2
      popup_menu.remove() if popup_menu != null

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
      starred: "/teacher/folders/starred"
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

  $("body").on "mousedown", "#root-folder .name-node", (event) ->
    if event.button is 2
      node_type = "folder"
      id = tree.folder_tree("get_folder_id_by_name_node", event.target)
      name = $(event.target).text()
      page_type = "folder"
      popup_menu = $("<div />").appendTo("body")
      if $(event.target).closest(".name-node").hasClass("root")
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
    rename($(this).closest("#renameModal"))

  $("#renameModal .target").keydown (event) ->
    code = event.which
    if code == 13
      rename($(this).closest("#renameModal"))

  rename = (modal) ->
    type = modal.attr("data-type")
    id = modal.attr("data-id")
    name = modal.find(".target").val()
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
    $.page_notification "正在打开文件夹", 0
    window.location.href = "/teacher/homeworks?folder_id=" + data.id

  $("body").on "click", ".popup-menu .edit", (event) ->
    data = popup_menu.popup_menu("option")
    $.page_notification "正在打开作业", 0
    window.location.href = "/teacher/homeworks/" + data.id

  $("body").on "click", "tr.record a .open", (event) ->
    open_doc_from_table($(event.target))

  $("body").on "click", "tr.record a .edit", (event) ->
    open_doc_from_table($(event.target))

  $("body").on "click", "tr.record .node-link", (event) ->
    open_doc_from_table($(event.target))

  open_doc_from_table = (node) ->
    tr = node.closest("tr")
    id = tr.attr("data-id")
    node_type = tr.attr("data-type")
    if node_type == "folder"
      $.page_notification "正在打开文件夹", 0
      window.location.href = "/teacher/homeworks?folder_id=" + id
    else
      $.page_notification "正在打开作业", 0
      window.location.href = "/teacher/homeworks/" + id
    false
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
    new_folder(parent_id, name)

  $("#newFolderModal .target").keydown (event) ->
    code = event.which
    if code == 13
      parent_id = $(this).closest("#newFolderModal").attr("data-folderid")
      name = $(this).closest("#newFolderModal").find(".target").val()
      new_folder(parent_id, name)

  new_folder = (parent_id, name) ->
    $.postJSON '/teacher/folders',
      {
        parent_id: parent_id 
        name: name
      }, (data) ->
        if data.success
          new_folder =
            id: data.folder._id.$oid
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
  intervalFunc = ->
    $('#file-name').html $('#file').val();
  $("#browser-click").click ->
    $("#file").click()
    setInterval(intervalFunc, 1)

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

  ######## Begin: move part ########
  $("body").on "click", ".popup-menu .move", (event) ->
    data = popup_menu.popup_menu("option")
    $('.popup-menu').remove()
    show_move_modal(data.type, data.id, data.name)

  $("body").on "click", "tr.record a .move", (event) ->
    tr = $(event.target).closest("tr")
    node_type = tr.attr("data-type")
    name = tr.attr("data-name")
    id = tr.attr("data-id")
    show_move_modal(node_type, id, name)

  show_move_modal = (node_type, id, name) ->
    $('#moveModal').modal('show')
    $("#moveModal").attr("data-type", node_type)
    $("#moveModal").attr("data-id", id)
    $("#moveModal").find('.target-name').text(name)
    $.getJSON "/teacher/folders", (data) ->
      if data.success
        move_tree = $("#moveModal #move-folder").folder_tree(
          content: data.tree
          root_folder_id: data.root_folder_id.$oid
          click_name_fun: (folder_id) ->
            move_tree.folder_tree("select_folder", folder_id)
        )
        move_tree.folder_tree("remove_folder", id) if node_type == "folder"
        move_tree.folder_tree("select_folder", data.root_folder_id.$oid)
        move_tree.folder_tree("open_folder", data.root_folder_id.$oid)
      else
        $.page_notification "服务器出错"

  $('#moveModal').on 'hidden.bs.modal', ->
    move_tree.folder_tree("destroy")

  $('#moveModal .ok').click ->
    move($(this).closest("#moveModal"))

  $('#moveModal #move-folder').keydown (event) ->
    code = event.which
    if code == 13
      move($(this))

  move = (modal) ->
    node_type = modal.attr("data-type")
    id = modal.attr("data-id")
    des_folder_id = move_tree.folder_tree("get_selected_folder_id")
    if node_type == "folder"
      $.putJSON '/teacher/folders/' + id + "/move",
        {
          des_folder_id: des_folder_id
        }, (data) ->
          if data.success
            tree.folder_tree("move_folder", id, des_folder_id)
            refresh_homework_table_and_folder_chain()
          else
            $.page_notification "操作失败，请刷新页面重试"
          modal.modal("hide")
    else
      # move a document
      $.putJSON '/teacher/homeworks/' + id + "/move",
        {
          folder_id: des_folder_id
        }, (data) ->
          if data.success
            refresh_homework_table_and_folder_chain()
          else
            $.page_notification "操作失败，请刷新页面重试"
          modalmodal("hide")
  ######## End: move part ########

  ######## Begin: delete part ########
  $("body").on "click", ".popup-menu .delete", (event) ->
    node_type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    delete_node(node_type, id)

  $("body").on "click", "tr.record a .remove", (event) ->
    tr = $(event.target).closest("tr")
    node_type = tr.attr("data-type")
    id = tr.attr("data-id")
    delete_node(node_type, id)

  delete_node = (node_type, id) ->
    if node_type == "folder"
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
    else if node_type == "homework"
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
    node_type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    recover_node(node_type, id)

  $("body").on "click", "tr.record a .recover", (event) ->
    tr = $(event.target).closest("tr")
    node_type = tr.attr("data-type")
    id = tr.attr("data-id")
    recover_node(node_type, id)

  recover_node = (node_type, id) ->
    $.putJSON "/teacher/#{node_type}s/#{id}/recover", { }, (data) ->
      if data.success
        window.location = "/teacher/homeworks?folder_id=" + data.parent_id
      else
        $.page_notification "操作失败，请刷新页面重试"
  ######## End: recover part ########

  ######## Begin: other redirect part ########
  $.each ["trash", "recent", "workbook", "starred", "all"], (i, v) ->
    $(".#{v}").click ->
      window.location = "/teacher/homeworks?type=#{v}"
  ######## End: other redirect part ########

  ######## Begin: destroy part ########
  $("body").on "click", ".popup-menu .destroy", ->
    node_type = popup_menu.popup_menu("option", "type")
    id = popup_menu.popup_menu("option", "id")
    destroy_node(node_type, id)

  $("body").on "click", "tr.record a .destroy", (event) ->
    tr = $(event.target).closest("tr")
    node_type = tr.attr("data-type")
    id = tr.attr("data-id")
    destroy_node(node_type, id)

  destroy_node = (node_type, id) ->
    data_url =
      folder: "/teacher/folders/#{id}"
      homework: "/teacher/homeworks/#{id}"
    $.deleteJSON data_url[node_type], { }, (data) ->
      if data.success
        $(".popup-menu").remove()
        refresh_homework_table_and_folder_chain()
      else
        $.page_notification "操作失败，请刷新页面重试"
  ######## End: destroy part ########

  ######## Begin: search part ########
  $("#btn-search").click ->
    keyword = $("#input-search").val()
    search(keyword)

  $("#input-search").keydown (event) ->
    code = event.which
    if code == 13
      search($(this).val())

  search = (keyword) ->
    window.location = "/teacher/homeworks?type=search&keyword=" + keyword
  ######## End: destroy part ########

  ######## Begin: add/remove star part #########
  $("body").on "click", ".star-link", (event) ->
    node_type = $(event.target).closest("tr").attr("data-type")
    id = $(event.target).closest("tr").attr("data-id")
    icon = $(event.target).closest(".star-link").find("i")
    add_star = icon.hasClass("star-empty")
    $.putJSON "/teacher/#{node_type}s/#{id}/star", {
      add: add_star
    }, (data) ->
      if data.success
        if add_star
          icon.removeClass("star-empty")
          icon.addClass("starred")
        else
          icon.addClass("star-empty")
          icon.removeClass("starred")
      else
        $.page_notification "操作失败，请刷新页面重试"


  $("body").on "click", "*[data-pagetype=trash] a.node-link", (event) ->
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
          text: "编辑"
          class: "edit"
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

