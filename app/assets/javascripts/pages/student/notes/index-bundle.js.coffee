#= require 'utility/ajax'
#= require "extensions/page_notification"
#= require 'jquery.tagsinput'
#= require 'jquery.autogrow-textarea'
#= require "./_templates/summary_paras"

$ ->
  $("#note_subject").val(window.subject)
  $("#note_time").val(window.time_period)
  $("#input-search").val(window.keyword)

  $(".note-wrapper").hover (->
    if $(this).attr("data-edit-tag") != "true"
      $(this).find(".note-operation-div").removeClass "hide"
  ), (->
    $(this).find(".note-operation-div").addClass "hide"
  )

  refresh_page = ->
    window.location.href = "?subject=#{window.subject}&keyword=#{window.keyword}&time_period=#{window.time_period}"


  $("#note_subject").change ->
    window.subject = $("#note_subject").val()
    refresh_page()

  $("#note_time").change ->
    window.time_period = $("#note_time").val()
    refresh_page()

  $("#link-search").click ->
    window.keyword = $("#input-search").val()
    refresh_page()

  $("#input-search").keydown (event) ->
    code = event.which
    if code == 13
      window.keyword = $("#input-search").val()
      refresh_page()

  update_topic = (note_id) ->
    topic_str = $("*[data-note-id=" + note_id + "]").find(".topics").val()
    $.putJSON "/student/notes/#{note_id}/update_topic_str",
      {
        topic_str: topic_str
      }, (data) ->
        if !data.success
          $.page_notification "操作失败，请刷新页面重试"

  $('.topics').tagsInput({
   'height': 'auto'
   'interactive': true
   'defaultText':'新知识点'
   'onRemoveTag' : ->
      note_id = $(this).closest(".note-wrapper").attr("data-note-id")
      update_topic(note_id)
   'onAddTag' : ->
      note_id = $(this).closest(".note-wrapper").attr("data-note-id")
      update_topic(note_id)
   'removeWithBackspace' : true
   'placeholderColor' : '#666666'
   # 'autocomplete_url': "/topics/list"
  })

  $(".span-wrapper").click ->
    $(this).addClass("hide")
    $(this).closest(".tag-part").find(".tag-edit").removeClass("hide")
    $(this).closest(".tag-part").find("select").focus()
    $(this).closest(".note-wrapper").attr("data-edit-tag", true)
    $(this).closest(".note-wrapper").find(".note-operation-div").addClass "hide"

  update_tag = (update, tag_part) ->
    if update
      note_id = tag_part.closest(".note-wrapper").attr("data-note-id")
      tag_index = tag_part.find("select").val()
      $.putJSON "/student/notes/#{note_id}/update_tag",
        {
          tag_index: tag_index
        }, (data) ->
          if data.success
            tag_part.find(".tag-content").text(data.tag)
            tag_part.find(".span-wrapper").removeClass("no-tag")
          else
            $.page_notification "操作失败，请刷新页面重试"
    tag_part.attr("data-edit", false)
    tag_part.find(".tag-edit").addClass("hide")
    tag_part.find(".span-wrapper").removeClass("hide")
    tag_part.closest(".note-wrapper").attr("data-edit-tag", false)

  $(".tag-ok").click ->
    update_tag(true, $(this).closest(".tag-part"))

  $(".tag-cancel").click ->
    update_tag(false, $(this).closest(".tag-part"))

  $(".summary-wrapper").click ->
    $(this).addClass("hide")
    summary_edit = $(this).closest(".summary-part").find(".summary-edit")
    summary_edit.removeClass("hide")
    summary_content = $(this).attr("data-summary")
    summary_edit.find(".summary-edit-textarea").val(summary_content)
    summary_edit.find(".summary-edit-textarea").autogrow()
    summary_edit.find(".summary-edit-textarea").focus()

  $(this).autogrow()

  update_summary = (update, summary_part) ->
    if update
      note_id = summary_part.closest(".note-wrapper").attr("data-note-id")
      summary = summary_part.find("textarea").val()
      $.putJSON "/student/notes/#{note_id}/update_summary",
        {
          summary: summary
        }, (data) ->
          if data.success
            summary_part.find(".summary-para").text(data.summary)
            summary_part.find(".summary-wrapper").empty()
            summary_part.find(".summary-wrapper").attr("data-summary", data.summary)
            if data.summary == ""
              summary_part.find(".summary-wrapper").addClass("no-summary")
              summary_part.find(".summary-wrapper").append("<p>未添加总结</p>")
            else
              summary_part.find(".summary-wrapper").removeClass("no-summary")
              summary_data = 
                summary: data.paras
              summary_paras = $(HandlebarsTemplates["summary_paras"](summary_data))
              summary_part.find(".summary-wrapper").append(summary_paras)
          else
            $.page_notification "操作失败，请刷新页面重试"
    summary_part.find(".summary-wrapper").removeClass("hide")
    summary_part.find(".summary-edit").addClass("hide")

  $(".summary-ok").click ->
    update_summary(true, $(this).closest(".summary-part"))

  $(".summary-cancel").click ->
    update_summary(false, $(this).closest(".summary-part"))

  $(".btn-delete-note").click ->
    r = confirm("确定删除？")
    return r

  $(".export-link").click ->
    $('#exportModal').modal('show')
    $("#exportModal").attr("data-note-id", "")


  $(".export-btn").click ->
    $('#exportModal').modal('show')
    note_id = $(this).closest(".note-wrapper").attr("data-note-id")
    $("#exportModal").attr("data-note-id", note_id)

  $("#exportModal form").submit ->
    note_id = $("#exportModal").attr("data-note-id")
    has_answer = $("#exportModal #include_answer").prop("checked")
    has_note = $("#exportModal #include_note").prop("checked")
    $("#exportModal").modal('hide')
    $.page_notification("正在导出，请稍后")
    if note_id == ""
      # export all searched notes
      $.postJSON '/student/notes/web_export',
        {
          keyword: window.keyword
          time_period: window.time_period
          subject: window.subject
          has_answer: has_answer
          has_note: has_note
        },
        (retval) ->
          if retval.success
            $.page_notification("导出完成，正在下载")
            window.location.href = "/" + retval.file_path
          else
            $.page_notification "操作失败，请刷新页面重试"
    else
      # export one note
      $.postJSON '/student/notes/web_export',
        {
          note_id: note_id
          has_answer: has_answer
          has_note: has_note
        },
        (retval) ->
          if retval.success
            $.page_notification("导出完成，正在下载")
            window.location.href = "/" + retval.file_path
          else
            $.page_notification "操作失败，请刷新页面重试"
    false

