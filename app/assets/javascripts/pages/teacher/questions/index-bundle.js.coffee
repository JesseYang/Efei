#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require "./_templates/books_ul"
#= require "extensions/page_notification"
$ ->

  tree = null

  refresh_structure = (book_id) ->
    $.getJSON "/teacher/structures/#{book_id}", (data) ->
      if data.success
        tree.folder_tree("destroy") if tree != null
        tree = $("#left-part #root-folder").folder_tree(
          content: data.tree
          root_folder_id: data.root_folder_id
          click_name_fun: undefined
        )
        tree.folder_tree("open_folder", data.root_folder_id)
      else
        $.page_notification "服务器出错"

  refresh_books = (edition_id) ->
    $.getJSON "/teacher/structures/#{edition_id}", (data) ->
      if data.success
        books_ul = $(HandlebarsTemplates["books_ul"]({ books: data.books}))
        $("#books-wrapper").empty()
        $("#books-wrapper").append(books_ul)
        tree.folder_tree("destroy") if tree != null
        tree = $("#left-part #root-folder").folder_tree(
          content: data.tree
          root_folder_id: data.root_folder_id
          click_name_fun: undefined
        )
        tree.folder_tree("open_folder", data.root_folder_id)
      else
        $.page_notification "服务器出错"

  refresh_structure(window.book_id)

  $(".edition-ele").click ->
    return if $(this).hasClass("selected")
    edition_id = $(this).attr("data-id")
    $(".edition-ele").removeClass("selected")
    $(this).addClass("selected")
    refresh_books(edition_id)

  $("body").on "click", ".book-ele", (event) ->
    ele = $(event.target)
    return if ele.hasClass("selected")
    book_id = ele.attr("data-id")
    $(".book-ele").removeClass("selected")
    ele.addClass("selected")
    refresh_structure(book_id)

  if window.show_compose == "true"
    $(".content-div").hover (->
      $(this).find(".compose-operation").removeClass "hide"
    ), (->
      $(this).find(".compose-operation").addClass "hide"
    )

  $(".content-div").each ->
    qid = $(this).attr("data-question-id")
    console.log qid
    if window.compose_qid_str.indexOf(qid) != -1
      $(this).find(".compose-status").removeClass("hide")

  $(".do-compose").click ->
    question_id = $(this).closest(".content-div").attr("data-question-id")
    that = this
    $.putJSON(
      '/teacher/composes/add',
      {
        question_id: question_id
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $(".compose-indicator .compose-question-number").text(retval.question_number)
          $(that).closest(".content-div").find(".compose-status").removeClass("hide")
    )

  $(".composed").click ->
    question_id = $(this).closest(".content-div").attr("data-question-id")
    that = this
    $.putJSON(
      '/teacher/composes/remove',
      {
        question_id: question_id
      },
      (retval) ->
        if !retval.success
          $.page_notification(retval.message)
        else
          $(".compose-indicator .compose-question-number").text(retval.question_number)
          $(that).closest(".content-div").find(".compose-status").addClass("hide")
          $(that).closest(".content-div").find(".compose-operation").addClass("hide")
    )

