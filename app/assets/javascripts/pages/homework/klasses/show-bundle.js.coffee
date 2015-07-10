$ ->
  $(".exam-summary").click ->
    exam_id = $(this).attr("data-id")
    window.location.href = "/homework/exams/" + exam_id
