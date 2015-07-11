#= require highcharts
$ ->
  # window.categories_str = 'A,B,C,D,未提交'
  # window.data_str = '4,5,3,4,1'
  data = [ ]
  $.each window.data_str.split(','), (i, v) ->
    data.push parseInt(v)

  $('.stat-pic-wrapper').highcharts({
          chart: {
              type: 'column'
          },
          credits:
            enabled: false
          title: {
              text: null
          },
          colors: ['#179C26'],
          xAxis: {
              # categories: ['A', 'B', 'C', 'D', '未提交'],
              categories: window.categories_str.split(','),
              crosshair: true
          },
          yAxis: {
              min: 0,
              title: { text: '人数' }
          },
          series: [{
              name: '人数',
              data: data

          }]
      });


  $(".edit-score").click ->
    $("#editScoreModal").modal("show")
    student_name = $(this).closest("tr").find(".name-td").text()
    score_text = $(this).closest("tr").find(".score-td").text()
    score_id = $(this).closest("tr").attr("data-id")
    $("#editScoreModal").attr("data-id", score_id)
    $("#modal-student-name").text(student_name)
    if window.type == "abcd"
      $(".score-abcd .icon").removeClass("select")
      $(".exam_" + score_text + "32").addClass("select")
    if window.type == "100"
      $(".score-100 input").val(score_text)

  $(".score-abcd a").click ->
    v = $(this).attr("data-value")
    $(this).closest(".score-abcd").attr("data-value", v)
    $(".score-abcd .icon").removeClass("select")
    $(this).find(".icon").addClass("select")

  $("#editScoreModal .ok").click ->
    score_id = $("#editScoreModal").attr("data-id")
    if window.type == "abcd"
      score = $(".score-abcd").attr("data-value")
      if score == ""
        $.page_notification "请先选择该学生的成绩"
        return
    if window.type == "100"
      score = $(".score-100 input").val()
      if score == ""
        $.page_notification "请先填写该学生的成绩"
        return
    $.putJSON '/homework/scores/' + score_id,
      {
        exam_id: window.exam_id
        score: score
      }, (data) ->
        if data.success
          $.page_notification "成绩更新成功"
          window.location.href = "/homework/exams/" + window.exam_id
        else
          $.page_notification "操作失败，请刷新页面重试"
