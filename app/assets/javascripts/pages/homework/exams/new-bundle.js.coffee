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
          window.exam_student_id_ary = [ ]
          window.exam_score_ary = [ ]
          $(".score-input").addClass("hide")
          if radio == "100"
            $(".score-100").removeClass("hide")
          if radio == "abcd"
            $(".score-abcd").removeClass("hide")
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
    window.current_student_id = sid
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

  $(".btn-next").click ->
    record_one_student()


  record_one_student = ->
    # save the score
    if window.type == "abcd"
      score = $(".score-abcd").attr("data-value")
      if score == ""
        $.page_notification "请先选择该学生的成绩"
        return
      window.exam_score_ary.push(score)
    if window.type == "100"
      score = $(".score-100 input").val()
      if score == ""
        $.page_notification "请先填写该学生的成绩"
        return
      window.exam_score_ary.push(score)
    # save the current student
    window.exam_student_id_ary << window.current_student_id

    # next student
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        t = result.split("/")
        sid = t[t.length - 1]
        refresh_new_student(sid)

  $(".btn-over").click ->
    record_one_student()
    # submit data, and return the the exam page
    $.putJSON '/homework/exams/' + window.exam_id,
      {
        student_id_ary: window.exam_student_id_ary
        score_ary: window.exam_score_ary
      }, (data) ->
        if data.success
          $.page_notification "成绩提交成功"
        else
          $.page_notification "操作失败，请刷新页面重试"

  $(".score-abcd a").click ->
    v = $(this).attr("data-value")
    $(this).closest(".score-abcd").attr("data-value", v)
    $(".score-abcd .icon").removeClass("select")
    $(this).find(".icon").addClass("select")
