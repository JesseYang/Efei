#= require 'utility/ajax'
#= require jquery.qtip
$(document).ready ->

  ################ operations about groups ###################
  $(".select-tooltip").hover ->
    $(this).tooltip('show')

  $(".group-div").hover (->
    edit_question = false
    $(this).find(".question-editor-div").each ->
      edit_question = edit_question || !$(this).hasClass("hide")
    if $(this).find(".editor-div").hasClass("hide") && !edit_question
      $(this).find(".operation-div").removeClass('hide')
  ), ->
    $(this).find(".operation-div").addClass('hide')

  $(".operation-div a").click ->
    $(this).closest(".group-div").find('.question-content-div').qtip('disable');
    $(this).closest(".group-div").find(".editor-div").removeClass("hide")
    $(this).closest(".group-div").find(".operation-div").addClass("hide")
    if !$(this).closest(".group-div").find(".select-style").data("random")
      $(this).closest(".group-div").find(".select-div label").removeClass("hide")
    $(this).closest(".group-div").find(".select-indicator").addClass("hide")
    false

  $(".editor-div .random").click ->
    $(this).closest(".editor-div").find(".random-number").attr("disabled", false)
    $(this).closest(".group-div").find(".select-div label").addClass("hide")

  $(".editor-div .fixed").click ->
    $(this).closest(".editor-div").find(".random-number").attr("disabled", true)
    $(this).closest(".group-div").find(".select-div label").removeClass("hide")

  $(".cancel").click ->
    $(this).closest(".group-div").find('.question-content-div').qtip('enable');
    $(this).closest(".editor-div").addClass("hide")
    $(this).closest(".group-div").find(".operation-div").removeClass("hide")
    $this = $(this)
    set_options($this)
    false

  $(".ok").click ->
    $(this).closest(".group-div").find('.question-content-div').qtip('enable');
    random_select = $(this).closest(".editor-div").find(".random").hasClass("active")
    random_number = $(this).closest(".editor-div").find(".random-number").val()
    manual_select = []
    $(this).closest(".group-div").find(".select-div").each ->
      if $(this).find("input").prop('checked')
        manual_select.push $(this).data("question-id")
    console.log parseInt(random_number)
    console.log $(this).closest(".group-div").find(".select-div").length
    if random_select && parseInt(random_number) > $(this).closest(".group-div").find(".select-div").length
      $(this).closest(".editor-div").find(".input-group").addClass("has-error")
      $(this).closest(".editor-div").find(".input-group").tooltip("show")
      return false
    $this = $(this)
    $.postJSON(
      '/admin/groups/' + $(this).data("group-id") + '/update_select',
      {
        random_select: random_select,
        random_number: random_number,
        manual_select: manual_select
      },
      (retval) ->
        $this.closest(".editor-div").addClass("hide")
        $this.closest(".group-div").find(".operation-div").removeClass("hide")
        $this.closest(".editor-div").find(".select-style").data("random", random_select)
        $this.closest(".editor-div").find(".random-number").data("random-number", random_number)
        $this.closest(".group-div").find(".select-div").each ->
          qid = $(this).data("question-id")
          $(this).data("selected", (!random_select && qid in manual_select))
        set_options($this)
    )
    false

  $(".editor-div .input-group input").focus ->
    $(this).closest(".input-group").removeClass("has-error")

  # set the editors based on the current data
  set_options = (btn_ele) ->
    # set select-div
    fix_number = 0
    btn_ele.closest(".group-div").find(".select-div").each ->
      if $(this).data("selected")
        $(this).find(".select-indicator").removeClass("hide")
        $(this).find("input").prop('checked', true)
        fix_number = fix_number + 1
      else
        $(this).find(".select-indicator").addClass("hide")
        $(this).find("input").prop('checked', false)
      $(this).find("label").addClass("hide")
    # set the editor-div
    random_select = btn_ele.closest(".editor-div").find(".select-style").data("random")
    if random_select
      btn_ele.closest(".editor-div").find(".random").addClass("active")
      btn_ele.closest(".editor-div").find(".fixed").removeClass("active")
      btn_ele.closest(".editor-div").find(".random-number").attr("disabled", false)
    else
      btn_ele.closest(".editor-div").find(".random").removeClass("active")
      btn_ele.closest(".editor-div").find(".fixed").addClass("active")
      btn_ele.closest(".editor-div").find(".random-number").attr("disabled", true)
    random_number = btn_ele.closest(".editor-div").find(".random-number").data("random-number")
    btn_ele.closest(".editor-div").find(".random-number").val(random_number)
    # set operation-div 
    if random_select
      btn_ele.closest(".group-div").find(".glyphicon-random").removeClass("hide")
      btn_ele.closest(".group-div").find(".glyphicon-hand-up").addClass("hide")
    else
      btn_ele.closest(".group-div").find(".glyphicon-random").addClass("hide")
      btn_ele.closest(".group-div").find(".glyphicon-hand-up").removeClass("hide")
    if random_select
      str = "随机选择" + random_number + "道题"
    else
      str = "手动选择" + fix_number + "道题"
    btn_ele.closest(".group-div").find(".select-tooltip").attr('data-original-title', str).tooltip('fixTitle')
  
  $(".question-div").click ->
    label = $(this).closest(".question-with-select-div").find("label")
    if !label.hasClass("hide")
      label.find("input").prop('checked', !label.find("input").prop('checked'))

  ################ operations about questions ###################
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

  $(".question-with-select-div").dblclick ->
    return if !$(this).closest(".group-div").find(".editor-div").hasClass("hide")
    # get basic information
    qid = $(this).find(".select-div").data("question-id")
    qtype = $(this).data("question-type")
    q_div = $(this).find(".question-div")
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

  $(".question-cancel").click ->
    leave_question_editor($(this).closest(".question-div"))
    false

  $(".question-ok").click ->
    # get basic information
    qid = $(this).closest(".question-with-select-div").find(".select-div").data("question-id")
    qtype = $(this).closest(".question-with-select-div").data("question-type")
    q_div = $(this).closest(".question-div")

    # get updated content
    question_content = q_div.find(".question-editor-div .question-content-editor").val()
    question_answer = q_div.find(".question-editor-div .question-answer-editor").val()
    if qtype == "choice"
      answer = $("input[name=" + qid + "-item-select]:checked", "." + qid + "-items-edit-div").val()
      items = []
      q_div.find(".question-editor-div .item-text-input").each ->
        items.push $(this).val()
    $.putJSON(
      '/admin/questions/' + $(this).data("question-id"),
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

  enter_question_editor = (q_div, qtype) ->
    q_div.closest(".group-div").find(".operation-div").addClass("hide")
    q_div.find(".question-editor-div").removeClass("hide")
    q_div.find(".question-editor-confirm-div").removeClass("hide")
    q_div.find(".question-content-div").addClass("hide")
    if qtype == "choice"
      q_div.find(".question-editor-div").find(".input-group").removeClass("hide")
    else
      q_div.find(".question-editor-div").find(".input-group").addClass("hide")

  leave_question_editor = (q_div) ->
    q_div.closest(".group-div").find(".operation-div").removeClass("hide")
    q_div.find(".question-editor-div").addClass("hide")
    q_div.find(".question-editor-confirm-div").addClass("hide")
    q_div.find(".question-content-div").removeClass("hide")
