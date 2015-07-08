#= require 'utility/ajax'
$ ->

  ## klass select and unselect ##
  $(".span-wrapper").click ->
    input = $(this).closest(".klass-wrapper").find("input")
    input.prop("checked", !input.prop("checked"))
    klass_select_changed($(this).closest(".klass-wrapper"))

  $(".klass-wrapper input").change ->
    klass_select_changed($(this).closest(".klass-wrapper"))

  klass_select_changed = (wrapper) ->
    input = wrapper.find("input")
    if input.prop("checked")
      wrapper.addClass("selected")
    else
      wrapper.removeClass("selected")

  ## submit result
  $("#submit-link").click ->
    klass_id_ary = [ ]
    $(".klass-wrapper").each ->
      if $(this).find("input").prop("checked")
        klass_id_ary.push($(this).attr("data-id"))
    if klass_id_ary.length == 0
      $.page_notification "至少选择一个班级"
      return
    klass_id_str = klass_id_ary.join(",")

    $.postJSON '/homework/klasses',
      {
        klass_id_str: klass_id_str
      }, (data) ->
        if data.success
          $.page_notification "班级更新完毕，正在跳转"
          window.location.href = "/homework/klasses"
        else
          $.page_notification "操作失败，请刷新页面重试"


