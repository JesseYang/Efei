$ ->
  weixin_jsapi_authorize(["scanQRCode"])

  window.student_id_ary = window.student_id_str.split(',')
  window.student_name_ary = window.student_name_str.split(',')
  window.exam_student_id_ary = [ ]
  window.exam_score_ary = [ ]

  wx.ready ->
    wx.scanQRCode
      needResult: 1
      scanType: ["qrCode"]
      success: (res) ->
        result = res.resultStr
        t = result.split("/")
        sid = t[t.length - 1]
        refresh_new_student(sid)

  refresh_new_student = (sid) ->
    index = window.student_id_ary.indexOf(sid)
    if index == -1
      return
    window.current_student_id = sid
    name = window.student_name_ary[index]
    $("h1#title").text(name)

  $(".praise").click ->
    if $(this).find(".icon").hasClass("star_select")
      $(this).find(".icon").removeClass("star_select")
      $(this).find("span").text("提出表扬")
    else
      $(this).find(".icon").addClass("star_select")
      $(this).find("span").text("取消表扬")

  $(".btn-next").click ->
    if record_one_student()
      # next student
      wx.scanQRCode
        needResult: 1
        scanType: ["qrCode"]
        success: (res) ->
          result = res.resultStr
          t = result.split("/")
          sid = t[t.length - 1]
          refresh_new_student(sid)

  record_one_student = ->
    # save the score
    if window.type == "abcd"
      score = $(".score-abcd").attr("data-value")
      $(".score-abcd .icon").removeClass("select")
      if score == ""
        $.page_notification "请先选择该学生的成绩"
        return false
      window.exam_score_ary.push(score)
    if window.type == "100"
      score = $(".score-100 input").val()
      if score == ""
        $.page_notification "请先填写该学生的成绩"
        return false
      window.exam_score_ary.push(score)
    # save the current student
    window.exam_student_id_ary.push(window.current_student_id)
    return true

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
          window.location.href = "/homework/exams/" + window.exam_id
        else
          $.page_notification "操作失败，请刷新页面重试"

  $(".score-abcd a").click ->
    v = $(this).attr("data-value")
    $(this).closest(".score-abcd").attr("data-value", v)
    $(".score-abcd .icon").removeClass("select")
    $(this).find(".icon").addClass("select")
