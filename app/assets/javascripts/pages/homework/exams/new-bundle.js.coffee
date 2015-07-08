$ ->
  $(".btn-create").click ->
    title = $("input#title").val()
    radio = $('input:radio:checked').val()
    $.postJSON '/homework/exams',
      {
        title: title
        type: radio
        klass_id: window.klass_id
      }, (data) ->
        if data.success
          $.page_notification "创建成功，正在跳转"
          window.location.href = "/homework/exams/" + data.id + "/entry"
        else
          $.page_notification "操作失败，请刷新页面重试"
