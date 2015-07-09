$ ->
  weixin_jsapi_authorize(["scanQRCode"])
  
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
          window.student_id_ary = data.student_id_ary
          window.student_name_ary = data.student_name_ary
          window.exam_id = data.exam_id
          window.type = radio
          wx.scanQRCode
            needResult: 1
            scanType: ["qrCode"]
            success: (res) ->
              result = res.resultStr
              t = result.split("/")
              sid = t[t.length - 1]
              refresh_new_student(sid)
        else
          $.page_notification "操作失败，请刷新页面重试"


  refresh_new_student = (sid) ->
    index = window.student_id_ary.indexOf(sid)
    if index == -1
      return
    name = window.student_name_ary[index]
    $("h1#title").text(name)
    $(".pre-entry").addClass("hide")
    $(".entry").removeClass("hide")

  $(".praise").click ->
    if $(this).find(".icon").hasClass("star_select")
      $(this).find(".icon").removeClass("star_select")
      $(this).find("span").text("提出表扬")
    else
      $(this).find(".icon").addClass("star_select")
      $(this).find("span").text("取消表扬")

