#= require 'utility/ajax'
#= require 'jquery.smartFloat'
#= require "extensions/page_notification"
#= require "./_templates/tag_set_item"

$ ->
  check_tag_set_selection = ->
    v = $('input[name=tag_set]:checked', 'form').val()
    if v == undefined
      $($('*[data-default=true]')[0]).find("input").prop("checked", true)

  check_tag_set_selection()

  $("#datepicker").datepicker(
    onSelect: (date) ->
      $("#time_later").prop("checked", true)
  )
  $("#datepicker").datepicker("option", "dateFormat", "yy-mm-dd");

  $("input[name=time]").change ->
    if this.value == "now"
      $("#datepicker").val("")


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

  $("#newTagSetModal .ok").click ->
    modal = $(this).closest(".modal")
    tag_set = modal.find(".target").val()
    if tag_set == ""
      notification = $("<div />").appendTo(modal) 
      notification.notification
        content: "请输入标签设置"
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

  $("#editTagSetModal .ok").click ->
    id = $("#editTagSetModal").attr("data-id")
    tag_set = $("#editTagSetModal").find(".target").val()
    if tag_set == ""
      notification = $("<div />").appendTo(modal) 
      notification.notification
        content: "请输入标签设置"
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

  $("#submit-btn a").click ->
    if window.type == "tag"
      # update tag set
    else if window.type == "basic"
      # basic setting
      title = $("form #title-edit-wrapper input").val()
      answer_time_type = $("form #answer-time-wrapper input[name=time]:checked").val()
      answer_time = $("form #answer-time-wrapper #datepicker").val()
      if answer_time_type == "later" && answer_time == ""
        $.page_notification "请指定具体答案公布时间"
        return
    else

