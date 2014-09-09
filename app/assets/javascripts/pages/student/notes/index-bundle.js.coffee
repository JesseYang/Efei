#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
#= require 'utility/tools'
#= require jquery-ui.js
#= require jquery.tagsinput.js
$ ->
  console.log $('.tags').length
  $('.tags').each ->
    $(this).tagsInput({
      'autocomplete_url': "http://b-fox.cn/topics?subject=" + window.subject,
      'defaultText': "",
      'width': '100%',
      'height': '20px'
    })
  $(".ui-autocomplete-input").attr("placeholder", "添加知识点")
  $('.tags').each ->
    topics = $(this).closest('.note-div').data("topics")
    $(this).importTags(topics)
  $('.summary').each ->
    summary = $(this).closest('.note-div').data("summary")
    $(this).height(1).val(summary).autogrow()

  $("#subject-select").change ->
    search()
  $("#period-select").change ->
    search()
  $("#note_type-select").change ->
    search()
  $("#btn-search").click ->
    search()
  $("#input-search").keydown (e) ->
    search() if e.which == 13


  $(".update_note").click ->
    nid = $(this).data("note-id")
    parent_div = $(this).closest("div")
    note_type = parent_div.find(".note_type-select").val()
    topics = parent_div.find(".tags").val()
    summary = parent_div.find(".summary").val()
    $this = $(this)
    info = {note_type: note_type, topics: topics, summary: summary}
    $.putJSON(
      "/student/notes/#{nid}",
      info,
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          window.location.href = "/users/sign_in"
        else
          $("#app-notification").notification({content: "更新成功"})
    )
    false

  search = ->
    subject = $("#subject-select").val()
    period = $("#period-select").val()
    note_type = $("#note_type-select").val()
    keyword = $("#input-search").val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject + "&period=" + period + "&note_type=" + note_type + "&keyword=" + keyword

  $(".show-answer-btn").click ->
    if $(".question-answer").hasClass("hide")
      $(".question-answer").removeClass("hide")
    else
      $(".question-answer").addClass("hide")

  $('input:radio[name=export-type]').change ->
    if this.value == "email"
      $("#email-input").attr("disabled", false)
    else
      $("#email-input").attr("disabled", true)

  $("#export-btn").click ->
    # check the illegal of email
    if $("#email-radio").is(":checked") && !$.validateEmail($("#email-input").val())
      $("#export-notification").notification({content: "请输入正确格式的邮箱"})
      return
    $("#export-btn").text("正在导出...")
    $("#export-btn").attr("disabled", true)
    $this = $(this)
    $.getJSON(
      '/student/notes/export',
      {
        has_answer: $("#answer-checkbox").is(":checked"),
        has_note: $("#note-checkbox").is(":checked"),
        send_email: $("#email-radio").is(":checked"),
        email: $("#email-input").val(),
        note_id_str: window.note_id_str
      },
      (retval) ->
        $('#export').modal('toggle')
        $this.attr("disabled", false)
        $this.text("导出")
        console.log retval.file_path
        if $("#email-radio").is(":checked")
          $("#app-notification").notification({content: "已导出并发送至" + $("#email-input").val()})
        else
          window.open "/" + retval.file_path
          $('#download a').attr("href", "/" + retval.file_path)
          $('#download').modal('toggle')
    )

  $("#check_questions").click ->
    $.get(
      '/student/questions/' + $(this).data("question-id") + '/similar',
      { },
      (retval) ->
        $(".page-operation-div").addClass("hide")
        $(".question-operation-div").removeClass("hide")
        $("#similar-questions-div").html(retval)
        $("#similar-questions-div").slideDown()
    )
    false

  $("#append_note").click ->
    $this = $(this)
    $.postJSON(
      '/student/questions/' + $(this).data("question-id") + '/append_note',
      { },
      (retval) ->
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          $('#sign').modal({
            show: 'false'
          });
        else
          $this.attr("disabled", true)
          $this.html("已加入错题本")
    )
    false

  $("form#sign_in_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      # hide the sign modal
      $('#sign').modal('hide')
      # append the question to the note
      $.postJSON(
        '/student/questions/' + $("#append_note").data("question-id") + '/append_note',
        { },
        (retval) ->
          $("#append_note").attr("disabled", true)
          $.refresh_navbar($("#sign_in_user #user_email").val())
      )
      # show the notification
      $("#app-notification").notification({content: "登录成功，已加入错题本"})
    else
      $("#sign-notification").notification({content: "邮箱或密码错误"})
      
  $("form#sign_up_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      # hide the sign modal
      $('#sign').modal('hide')
      # append the question to the note
      $.postJSON(
        '/student/questions/' + $("#append_note").data("question-id") + '/append_note',
        { },
        (retval) ->
          $("#append_note").attr("disabled", true)
          $.refresh_navbar($("#sign_up_user #user_email").val())
      )
      # show the notification
      $("#app-notification").notification({content: "注册成功，已加入错题本"})
    else
      $("#sign-notification").notification({content: "注册失败"})
