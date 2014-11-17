#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require 'ui/widgets/popup_menu'
#= require "extensions/page_notification"
$ ->

  # forbit the default right-click popup menu
  $("body").bind "contextmenu", ->
    false

  # get the tree stucture
  tree = null
  move_tree = null
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

  $("body").on "mousedown", "#root-folder .name", ->
    if event.button is 2
      name = $(event.target).text()
      folder_id = tree.folder_tree("get_folder_id_by_name_node", event.target)
      popup_menu = $("<div />").appendTo("body")
      type = "folder"
      if $(event.target).closest(".folder-list").hasClass("root")
        type = "root"
      popup_menu.popup_menu
        pos: [
          event.pageX
          event.pageY
        ]
        content: generate_popup_menu(folder_id, type)
        id: folder_id
        type: type
        name: name
      event.stopPropagation()


  ######## Begin: rename part ########
  $("body").on "click", ".popup-menu .rename", ->
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
            $.page_notification "重命名成功"
          else
            $.page_notification "操作失败，请刷新页面重试"
          $("#renameModal").modal("hide")
    else
      # rename a doc

  ######## End: rename part ########

  ######## Begin: new folder part ########
  $("body").on "click", ".popup-menu .new-folder", ->
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
          $.page_notification "文件夹创建成功"
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newFolderModal").modal("hide")
  ######## End: new folder part ########

  ######## Begin: new homework part ########
  $("body").on "click", ".popup-menu .new-doc", ->
    folder_id = $(event.target).closest(".data-store").attr("data-id")
    $('.popup-menu').remove()
    $('#newHomeworkModal').modal('show')
    $("#newHomeworkModal #folder_id").val(folder_id)
  ######## End: new homework part ########

  ######## Begin: move folder part ########
  $("body").on "click", ".popup-menu .move", ->
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
            $.page_notification "移动成功"
          else
            $.page_notification "操作失败，请刷新页面重试"
          $("#moveModal").modal("hide")
    else
      # move a document
  ######## End: move folder part ########


  ######## Begin: delete part ########
  $("body").on "click", ".popup-menu .delete", ->
    type = $(event.target).closest(".data-store").attr("data-type")
    id = $(event.target).closest(".data-store").attr("data-id")
    if type == "folder"
      $.deleteJSON "/teacher/folders/" + id, {}, (data) ->
        if data.success
          tree.folder_tree("remove_folder", id)
          $(".popup-menu").remove()
          $.page_notification "文件夹删除成功"
        else
          $.page_notification "操作失败，请刷新页面重试"
    else if type == "doc"
      $.deleteJSON "/teacher/homeworks/" + id, {}, (data) ->
        if data.success
          $(".popup-menu").remove()
  ######## End: delete part ########

  ######## Begin: redirect part ########
  redirect_folder = (folder_id) ->
    window.location = '/teacher/homeworks?folder_id=' + folder_id
  ######## End: redirect part ########

  $("body").on "click", ".popup_menu .new-doc", ->
    # the upload document dialog

  generate_popup_menu = (id, type) ->
    if type == "root"
      [
        {
          text: "新建文件夹"
          class: "new-folder"
        }
        {
          text: "新建文件"
          class: "new-doc"
        }
      ]
    else if type == "folder"
      [
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
      ]
