//= require 'utility/ajax'
$ ->

  $(".group-div").hover (->
    edit_question = false
    $(this).find(".question-editor-div").each ->
      edit_question = edit_question || !$(this).hasClass("hide")
    if $(this).find(".editor-div").hasClass("hide") && !edit_question
      $(this).find(".operation-div").removeClass('hide')
  ), ->
    $(this).find(".operation-div").addClass('hide')

  $(".operation-div a").click ->
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
    $(this).closest(".group-div").find(".editor-div").addClass("hide")
    $(this).closest(".group-div").find(".operation-div").removeClass("hide")
    $this = $(this)
    set_options($this)
    false

  $(".ok").click ->
    $(this).closest(".group-div").find(".editor-div").addClass("hide")
    $(this).closest(".group-div").find(".operation-div").removeClass("hide")
    random_select = $(this).closest(".editor-div").find(".random").hasClass("active")
    random_number = $(this).closest(".editor-div").find(".random-number").val()
    manual_select = []
    $(this).closest(".group-div").find(".select-div").each ->
      if $(this).find("input").prop('checked')
        manual_select.push $(this).data("question-id")
    $this = $(this)
    $.postJSON(
      '/admin/groups/' + $(this).data("group-id") + '/update_select',
      {
        random_select: random_select,
        random_number: random_number,
        manual_select: manual_select
        },
      (retval) ->
        $this.closest(".editor-div").find(".select-style").data("random", random_select)
        $this.closest(".editor-div").find(".random-number").data("random-number", random_number)
        $this.closest(".group-div").find(".select-div").each ->
          qid = $(this).data("question-id")
          $(this).data("selected", (!random_select && qid in manual_select))
        set_options($this)
    )
    false

  $(".question-div").click ->
    label = $(this).closest(".question-with-select-div").find("label")
    if !label.hasClass("hide")
      label.find("input").prop('checked', !label.find("input").prop('checked'))


  $(".question-div").hover (->
    if $(this).find(".question-editor-div").hasClass("hide") && $(this).closest(".group-div").find(".editor-div").hasClass("hide")
      $(this).find(".question-operation-div").removeClass('hide')
  ), ->
    $(this).find(".question-operation-div").addClass('hide')

  $(".question-operation-div a").click ->
    $(this).closest(".group-div").find(".operation-div").addClass("hide")
    q_div = $(this).closest(".question-div")
    q_div.find(".question-editor-div").removeClass("hide")
    q_div.find(".question-editor-confirm-div").removeClass("hide")
    q_div.find(".question-operation-div").addClass("hide")
    q_div.find(".question-content-div").addClass("hide")
    content = q_div.find(".question-content p").html()
    q_div.find("textarea").height(1);
    q_div.find("textarea").val(content)
    q_div.find("textarea").autogrow()
    items = []
    q_div.find(".question-items span").each ->
      items.push $(this).html()
    index = 0
    q_div.find(".question-editor-div input").each ->
      $(this).val(items[index++])
    false

  $(".question-cancel").click ->
    $(this).closest(".group-div").find(".operation-div").removeClass("hide")
    $(this).closest(".question-div").find(".question-editor-div").addClass("hide")
    $(this).closest(".question-div").find(".question-editor-confirm-div").addClass("hide")
    $(this).closest(".question-div").find(".question-operation-div").removeClass("hide")
    $(this).closest(".question-div").find(".question-content-div").removeClass("hide")
    false

  $(".question-ok").click ->
    $(this).closest(".group-div").find(".operation-div").removeClass("hide")
    q_div = $(this).closest(".question-div")
    content = q_div.find(".question-editor-div textarea").val()
    items = []
    q_div.find(".question-editor-div input").each ->
      items.push $(this).val()
    $.putJSON(
      '/admin/questions/' + $(this).data("question-id"),
      {
        content: content,
        items: items
        },
      (retval) ->
        q_div.find(".question-editor-div").addClass("hide")
        q_div.find(".question-editor-confirm-div").addClass("hide")
        q_div.find(".question-operation-div").removeClass("hide")
        q_div.find(".question-content-div").removeClass("hide")
        q_div.find(".question-content p").html(retval.content)
        index = 0
        q_div.find(".question-items span").each ->
          $(this).html(retval.items[index++])
    )
    false

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
