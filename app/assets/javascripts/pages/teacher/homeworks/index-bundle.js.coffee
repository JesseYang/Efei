#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require 'ui/widgets/popup_menu'
$ ->
  # forbit the default right-click popup menu
  $("body").bind "contextmenu", ->
    false

  # get the tree stucture
  tree = null
  $.getJSON "/teacher/folders", (data) ->
    if data.success
      tree = $("#left-part #root-folder").folder_tree(
        content: data.tree
        root_folder_id: data.root_folder_id
        click_name_fun: redirect_folder
      )
      tree.folder_tree("select_folder", window.folder_id)


  $("body").on "mousedown", "#root-folder .name", ->
    if event.button is 2
      console.log $(event.target).text()
      folder_id = tree.folder_tree("get_folder_id_by_name_node", event.target)
      content = 
      popup_menu = $("<div />").appendTo("body")
      popup_menu.popup_menu
        pos: [
          event.pageX
          event.pageY
        ]
        content: generate_popup_menu(folder_id, "folder")
      event.stopPropagation()


  ######## Begin: new folder part ########
  $("body").on "click", ".popup-menu .new-folder", ->
    # the new folder name dialog
    folder_id = $(event.target).closest(".new-folder").data("id")
    $('.popup-menu').remove()
    $('#newFolderModal').modal('show')
    $("#newFolderModal").data("folder_id", folder_id)
    $("#newFolderModal #target").focus()

  $('#newFolderModal').on 'shown.bs.modal', ->
    $('.target').focus()
    $('.target').select()

  $("#newFolderModal .ok").click ->
    parent_id = $(this).closest("#newFolderModal").data("folder_id")
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
        else
        $("#newFolderModal").modal("hide")
  ######## End: new folder part ########

  ######## Begin: delete part ########
  $("body").on "click", ".popup-menu .delete", ->
    type = $(event.target).data("type")
    id = $(event.target).data("id")
    if type == "folder"
      $.deleteJSON "/teacher/folders/" + id, {}, (data) ->
        if data.success
          tree.folder_tree("remove_folder", id)
          $(".popup-menu").remove()
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
    if id == "root"
      [
        {
          text: "新建文件夹"
          id: id
          class: "new-folder"
          type: type
        }
        {
          text: "新建文件"
          id: id
          class: "new-doc"
          type: type
        }
      ]
    else if type == "folder"
      [
        {
          text: "新建文件夹"
          id: id
          class: "new-folder"
          type: type
        }
        {
          text: "新建文件"
          id: id
          class: "new-doc"
          type: type
        }
        {
          hr: true
        }
        {
          text: "移动"
          id: id
          class: "move"
          type: type
        }
        {
          text: "删除"
          id: id
          class: "delete"
          type: type
        }
      ]
