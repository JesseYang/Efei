#= require 'utility/ajax'
$ ->
  $(".admin-nav .supers").addClass("active")

  $(".btn-update").click ->
    tr = $(this).closest("tr")
    uid = tr.attr("data-id")
    permission = 0
    targets = tr.find("input:checked")
    targets.each ->
      permission += parseInt($(this).val())
    $.putJSON "/admin/supers/#{uid}", {permission: permission}, (data) ->
      if data.success
        $.page_notification "更新成功"
      else
        $.page_notification "操作失败，请刷新页面重试"
