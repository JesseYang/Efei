#= require 'utility/ajax'
#= require jquery.qtip
$(document).ready ->

  $(".tooltips").hover ->
    $(this).tooltip('show')


  $(".wrap h2").dblclick ->
    $(this).addClass("hide")
    $(this).closest(".wrap").find(".title-edit").removeClass("hide")

  $(".title-cancel").click ->
    $(this).closest(".wrap").find(".title-edit").addClass("hide")
    $(this).closest(".wrap").find("h2").removeClass("hide")

  $(".title-ok").click ->
    new_name = $(this).closest(".wrap").find("input").val()
    $this = $(this)
    $.postJSON(
      '/teacher/homeworks/' + $(this).data("homework-id") + '/rename',
      {
        name: new_name
      },
      (retval) ->
        $this.closest(".wrap").find("h2").html(new_name)
        $this.closest(".wrap").find(".title-edit").addClass("hide")
        $this.closest(".wrap").find("h2").removeClass("hide")
    )

  $(".title-edit input").keypress (e) ->
    if e.which is 13
      new_name = $(this).val()
      $this = $(this)
      homework_id = $(this).closest(".wrap").find(".title-ok").data("homework-id")
      $.postJSON(
        '/teacher/homeworks/' + homework_id + '/rename',
        {
          name: new_name
        },
        (retval) ->
          $this.closest(".wrap").find("h2").html(new_name)
          $this.closest(".wrap").find(".title-edit").addClass("hide")
          $this.closest(".wrap").find("h2").removeClass("hide")
      )

  # about homework list

  $("#privilege-select").change ->
    select_changed()

  $("#subject-select").change ->
    select_changed()

  select_changed = ->
    privilege = $("#privilege-select").val()
    subject = $("#subject-select").val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject + "&privilege=" + privilege

  $("#btn-search").click ->
    search()
  $("#input-search").keydown (e) ->
    search() if e.which == 13

  search = ->
    privilege = $("#privilege-select").val()
    subject = $("#subject-select").val()
    keyword = $("#input-search").val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject + "&privilege=" + privilege + "&keyword=" + keyword



  # about homework share

  $(".share-all").change ->
    share_all = $(this).is(":checked")
    $(".share-one").each ->
      $(this).prop("checked", share_all)
    $.putJSON(
      "/teacher/homeworks/" + window.homework_id + "/share_all",
      {
        share: share_all
      },
      (retval) ->
    )

  $(".share-one").change ->
    teacher_id = $(this).closest("tr").data("id")
    $this = $(this)
    $.putJSON(
      "/teacher/homeworks/" + window.homework_id + "/share",
      {
        teacher_id: teacher_id,
        share: $this.is(":checked")
      },
      (retval) ->
    )

  # about question edit
  $('.question-content-div').qtip({
      content: { text: '双击编辑' }
      position: {
          my: 'top left',
          target: 'mouse',
          viewport: $(window), # Keep it on-screen at all times if possible
          adjust: { x: 10,  y: 10 }
      },
      show: { delay: 100 },
      hide: { fixed: false },
      style: 'qtip-dark qtip-bootstrap'
  })

  $(".question-content-div").dblclick ->
    # get basic information
    q_div = $(this).closest(".question-div")
    qid = q_div.data("question-id")
    qtype = q_div.data("question-type")
    enter_question_editor(q_div, qtype)

    # get the information to show
    question_content = q_div.find(".for-edit-content").html()
    question_answer = q_div.find(".for-edit-answer").html()
    answer = $(this).find(".question-items").data("question-answer")

    # set content and answer in the editor
    q_div.find(".question-content-editor").height(1).val(question_content).autogrow()
    q_div.find(".question-answer-editor").height(1).val(question_answer).autogrow()

    # set items in the editor
    if qtype == "choice"
      items = []
      q_div.find(".question-items .for-edit").each ->
        items.push $(this).html()
      index = 0
      q_div.find(".question-editor-div .item-text-input").each ->
        $(this).val(items[index++])
      # set answer for choice question
      q_div.find(".question-editor-div #" + qid + "-" + answer).prop("checked", true)

  enter_question_editor = (q_div, qtype) ->
    q_div.find(".question-editor-div").removeClass("hide")
    q_div.find(".question-editor-confirm-div").removeClass("hide")
    q_div.find(".question-content-div").addClass("hide")
    if qtype == "choice"
      q_div.find(".question-editor-div").find(".input-group").removeClass("hide")
    else
      q_div.find(".question-editor-div").find(".input-group").addClass("hide")

  $(".question-ok").click ->
    # get basic information
    q_div = $(this).closest(".question-div")
    qid = q_div.data("question-id")
    qtype = q_div.data("question-type")

    # get updated content
    question_content = q_div.find(".question-editor-div .question-content-editor").val()
    question_answer = q_div.find(".question-editor-div .question-answer-editor").val()
    if qtype == "choice"
      answer = $("input[name=" + qid + "-item-select]:checked", "." + qid + "-items-edit-div").val()
      items = []
      q_div.find(".question-editor-div .item-text-input").each ->
        items.push $(this).val()
    $.putJSON(
      '/teacher/questions/' + $(this).data("question-id"),
      {
        question_content: question_content,
        question_answer: question_answer,
        items: items,
        answer: answer
      },
      (retval) ->
        console.log retval
        leave_question_editor(q_div)
        q_div.find(".question-content").html(retval.content_for_show)
        q_div.find(".question-answer").html(retval.answer_for_show)
        if retval.answer_for_show == ""
          q_div.find(".answer-label").addClass("hide")
          q_div.find(".question-answer").addClass("hide")
        else
          q_div.find(".answer-label").removeClass("hide")
          q_div.find(".question-answer").removeClass("hide")
        q_div.find(".for-edit-content").html(retval.content_for_edit)
        q_div.find(".for-edit-answer").html(retval.answer_for_edit)
        if qtype == "choice"
          index = 0
          q_div.find(".question-items .item-content").each ->
            $(this).html(retval.items_for_show[index++])
          index = 0
          q_div.find(".question-items .for-edit").each ->
            $(this).html(retval.items_for_edit[index++])
          q_div.find(".question-items p").addClass("item-is-not-answer")
          q_div.find("#" + qid + "-item-" + retval.answer).removeClass("item-is-not-answer")
          q_div.find(".question-items").data("question-answer", retval.answer)
    )
    false

  $(".question-cancel").click ->
    leave_question_editor($(this).closest(".question-div"))
    false

  leave_question_editor = (q_div) ->
    q_div.find(".question-editor-div").addClass("hide")
    q_div.find(".question-editor-confirm-div").addClass("hide")
    q_div.find(".question-content-div").removeClass("hide")