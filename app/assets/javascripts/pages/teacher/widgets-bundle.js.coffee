#= require 'extensions/out_click'
#= require 'extensions/up_key_down'
#= require 'extensions/down_key_down'
#= require 'extensions/right_mouse_down'
#= require 'ui/widgets/popup_menu'
#= require 'ui/widgets/folder_tree'
$(document).ready ->

  $("body").bind "contextmenu", ->
    false

  # folder tree part

  # create new folder
  tree = $("#root").folder_tree()
  new_folder = {
    id: "english"
    name: "english"
    children: []
  }
  tree.folder_tree("insert_folder", "root", new_folder)

  # create another new folder
  new_folder = {
    id: "first"
    name: "first exercise"
    children: []
  }
  tree.folder_tree("insert_folder", "function", new_folder)

  $("body").on "click", ".icon", ->
    tree.folder_tree("toggle_folder_by_icon_node", event.target)

  $("body").on "click", ".name", ->
    tree.folder_tree("select_folder_by_name_node", event.target)


  tree.folder_tree("select_folder", "function")

  $("body").on "mousedown", ".name", ->
    if event.button is 2
      console.log $(event.target).text()

  ###
  tree.folder_tree("open_folder", "first")
  tree.folder_tree("close_folder", "function")
  tree.folder_tree("select_folder", "function")
  tree.folder_tree("select_folder", "circle")
  ###

  ###
  # move folder
  tree.folder_tree("move_folder", "id1", "id4")

  # delete folder
  tree.folder_tree("remove_folder", "id1")
  ###


  ### popup menu part
  $("#sub_div").right_mouse_down (e) ->
    console.log "right mouse down"
    popup_menu = $("<div />").appendTo("body")
    popup_menu.popup_menu
      pos: [
        e.pageX
        e.pageY
      ]
      content: [
        {
          text: "create new"
          id: "11111"
          class: "22222"
        }
        {
          text: "delete"
          id: "33333"
          class: "44444"
        }
        {
          text: "export"
          id: "55555"
          class: "66666"
        }
      ]
    e.stopPropagation()

  $("body").on "click", ".popup-menu .22222", ->
    console.log "popup_menu create_new, id=" + $(event.target).attr("id")

  $("#div2").right_mouse_down (e) ->
    console.log "right mouse down"
    popup_menu = $("<div />").appendTo("body")
    popup_menu.popup_menu(pos: [e.pageX, e.pageY])
    e.stopPropagation()
  ###
