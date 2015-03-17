#= require 'utility/ajax'
#= require 'jquery.smartFloat'
#= require "extensions/page_notification"
#= require "./_templates/tag_set_item"

$ ->
  check_tag_set_selection = ->
    if window.tag_set_id != ""
      $("#tag_set_#{window.tag_set_id}").prop("checked", true)
    if window.tag_set == ""
      $($('*[data-default=true]')[0]).find("input").prop("checked", true)

  if window.type == "basic"
    $("#time_#{window.answer_time_type}").prop("checked", true)
    $("#datepicker").datepicker(
      dateFormat: "yy-mm-dd"
      onSelect: (date) ->
        $("#time_later").prop("checked", true)
    )
    if window.answer_time != ""
      $("#datepicker").datepicker("setDate", window.answer_time);
    else
      $("#datepicker").val("")
      
    $("input[name=time]").change ->
      if this.value == "now" || this.value == "no"
        $("#datepicker").val("")
  else
    check_tag_set_selection()



  $(document).on(
    mouseenter: (event) ->
      $(event.target).closest("li").find(".tag-set-operation").removeClass "hide"
    ,
    mouseleave: (event) ->
      $(event.target).closest("li").find(".tag-set-operation").addClass "hide"
    , ".tag-set-ul li")

  $("#new-tagset a").click ->
    $("#newTagSetModal .target").val("")
    $("#newTagSetModal").modal("show")

  newTagSet = ->
    modal = $("#newTagSetModal")
    tag_set = modal.find(".target").val()
    if tag_set == ""
      notification = $("<div />").appendTo(modal) 
      notification.notification
        content: "请输入标签设置"
      return
    $.postJSON '/teacher/tag_sets',
      {
        tag_set: tag_set
      }, (data) ->
        if data.success
          tag_set_data =
            id: data.tag_set._id
            tags: data.tag_set.tags.join(', ')
          console.log tag_set_data
          new_tag_set = $(HandlebarsTemplates["tag_set_item"](tag_set_data))
          $("ul.tag-set-ul").append(new_tag_set)
          $.page_notification "标签设置创建成功"
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#newTagSetModal").modal("hide")

  $("#newTagSetModal .ok").click ->
    newTagSet()

  $("#newTagSetModal input").keydown (event) ->
    code = event.which
    if code == 13
      newTagSet()

  $(document).on "click", ".remove-tag-set-link", (event) ->
    li = $(event.target).closest("li")
    id = li.attr("data-id")
    $.deleteJSON "/teacher/tag_sets/#{id}", { }, (data) ->
      if data.success
        $.page_notification "删除标签设置成功"
        li.remove()
        check_tag_set_selection()
      else
        $.page_notification "操作失败，请刷新页面重试"

  $(document).on "click", ".edit-tag-set-link", (event) ->
    tags = $(event.target).closest("li").find("label").text()
    id = $(event.target).closest("li").attr("data-id")
    $("#editTagSetModal .target").val(tags)
    $("#editTagSetModal").attr("data-id", id)
    $("#editTagSetModal").modal("show")

  editTagSet = ->
    id = $("#editTagSetModal").attr("data-id")
    tag_set = $("#editTagSetModal").find(".target").val()
    if tag_set == ""
      notification = $("<div />").appendTo(modal) 
      notification.notification
        content: "请输入标签设置"
      return
    $.putJSON "/teacher/tag_sets/#{id}",
      {
        tag_set: tag_set
      }, (data) ->
        if data.success
          tag_set = data.tag_set.tags.join(', ')
          $("ul.tag-set-ul").find('*[data-id="' + id + '"] label').text(tag_set)
          $.page_notification "标签设置修改成功"
        else
          $.page_notification "操作失败，请刷新页面重试"
        $("#editTagSetModal").modal("hide")

  $("#editTagSetModal .ok").click ->
    editTagSet()

  $("#editTagSetModal input").keydown (event) ->
    code = event.which
    if code == 13
      editTagSet()

  $("#submit-btn a").click ->
    if window.type == "tag"
      # update tag set
      tag_set_id = $("form input[name=tag_set]:checked").val()
      $.putJSON "/teacher/homeworks/#{window.homework_id}/set_tag_set",
        {
          tag_set_id: tag_set_id
        }, (data) ->
          if data.success
            $.page_notification "更新成功"
          else
            $.page_notification "操作失败，请刷新页面重试"
    else if window.type == "basic"
      # basic setting
      name = $("form #title-edit-wrapper input").val()
      answer_time_type = $("form #answer-time-wrapper input[name=time]:checked").val()
      answer_time = $("form #answer-time-wrapper #datepicker").val()
      if answer_time_type == "later" && answer_time == ""
        $.page_notification "请指定具体答案公布时间"
        return
      $.putJSON "/teacher/homeworks/#{window.homework_id}/set_basic_setting",
        {
          name: name
          answer_time_type: answer_time_type
          answer_time: answer_time
        }, (data) ->
          if data.success
            $.page_notification "更新成功"
          else
            $.page_notification "操作失败，请刷新页面重试"
    else

