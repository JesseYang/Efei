#= require 'utility/ajax'
#= require 'ui/widgets/folder_tree'
#= require "./_templates/books_ul"
#= require "./_templates/paper_table"
#= require "utility/_templates/paginator_mini"
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

  redirect_point = (point_id) ->
    window.location.href = "/teacher/questions?type=zhuanxiang&point_id=#{point_id}"

  refresh_point = (root_point_id) ->
    $.getJSON "/teacher/points/#{root_point_id}", (data) ->
      if data.success
        tree.folder_tree("destroy") if tree != null
        tree = $("#left-part #root-folder").folder_tree(
          content: data.tree
          root_folder_id: data.root_folder_id
          click_name_fun: redirect_point
        )
        tree.folder_tree("open_folder", data.root_folder_id)
        tree.folder_tree("select_folder", window.point_id)
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

  refresh_papers = (page) ->
    $.getJSON "/teacher/papers/list?page=#{page}&paper_year=#{window.paper_year}&paper_province=#{window.paper_province}&paper_type=#{window.paper_type}", (data) ->
      if data.success
        # render paginator
        paginator_mini = $(HandlebarsTemplates["paginator_mini"](data.papers))
        $(".zonghe-paginator").empty()
        $(".zonghe-paginator").append(paginator_mini)
        $("#zonghe-paginator-wrapper .search-tip").empty()
        $("#zonghe-paginator-wrapper .search-tip").append("<span>共搜索到" + data.papers.total_number + "份符合要求的试卷</span>")
        # render table
        paper_table = $(HandlebarsTemplates["paper_table"](data.papers))
        $("#paper-table-wrapper").empty()
        $("#paper-table-wrapper").append(paper_table)
      else
        $.page_notification "服务器出错"

  $("body").on "click", ".paginator-link", (event) ->
    ele = $(event.target).closest(".paginator-link")
    page = ele.attr("data-page")
    refresh_papers(page)
    false

  $("#paper_year").change ->
    window.paper_year = $(this).val()
    refresh_papers(1)

  $("#paper_province").change ->
    window.paper_province = $(this).val()
    refresh_papers(1)

  $("#paper_type").change ->
    window.paper_type = $(this).val()
    refresh_papers(1)
  ###
  refresh_questions = (point_id, page, per_page) ->
    $.getJSON "/teacher/questions/point_list?point_id=#{point_id}&page=#{page}&per_page=#{per_page}", (data) ->
      if data.success
        # render paginator and data table
        paginator_mini = $(HandlebarsTemplates["paginator_mini"](data.questions))
        $(".question-paginator-wrapper").empty()
        $(".question-paginator-wrapper").append(paginator_mini)
      else
        $.page_notification "服务器出错"

  $("body").on "click", ".paginator-link", (event) ->
    ele = $(event.target).closest(".paginator-link")
    page = ele.attr("data-page")
    per_page = ele.attr("data-per-page")
    refresh_questions(window.point_id, page, per_page)
    false
  ###

  if window.type == "tongbu"
    refresh_structure(window.book_id)
  else if window.type == "zhuanxiang"
    refresh_point(window.root_point_id)
  else if window.type == "zonghe"
    refresh_papers(1)

  $(".edition-ele").click ->
    return if $(this).hasClass("selected")
    edition_id = $(this).attr("data-id")
    $(".edition-ele").removeClass("selected")
    $(this).addClass("selected")
    refresh_books(edition_id)

  $(".root-point-ele").click ->
    point_id = $(this).attr("data-id")
    window.location.href = "/teacher/questions?type=zhuanxiang&point_id=#{point_id}"

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

  $(".content-div").hover (->
    $(this).find(".question-report-wrapper").removeClass "hide"
  ), (->
    $(this).find(".question-report-wrapper").addClass "hide"
  )

  $(".report-bug").click ->
    question_id = $(this).closest(".content-div").attr("data-question-id")
    $.postJSON(
      '/teacher/feedbacks',
      {
        question_id: question_id
      },
      (retval) ->
        if retval.success
          $.page_notification("谢谢！报错请求提交成功")
        else
          $.page_notification("服务器错误，请稍后再试")
    )

  $(".content-div").each ->
    qid = $(this).attr("data-question-id")
    if window.included_qid_str.indexOf(qid) != -1
      $(this).find(".include-status").removeClass("hide")
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

