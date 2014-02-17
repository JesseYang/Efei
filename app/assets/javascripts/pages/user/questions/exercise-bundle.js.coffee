#= require 'utility/ajax'
#= require 'utility/refresh_navbar'
$ ->
  $(".question-items p").click ->
    $(this).find("input").prop("checked", true)
    $(this).closest('.question-items').find(".thick").removeClass('thick')
    $(this).find("span").addClass('thick')

  $("#submit_answer").click ->
    qid_ary = []
    answer_ary = []
    $(".question-div").each ->
      qid = $(this).data("question-id")
      answer = $("input[name=" + qid + "-item-select]:checked").val()
      qid_ary.push qid
      answer_ary.push answer
      console.log qid
      console.log answer
    if $.inArray(undefined, answer_ary) != -1
      console.log 'some questions are not answered'

    else
      console.log 'all questions are not answered'
      $.postJSON(
        '/user/questions/answer',
        {
          qid_ary: qid_ary,
          answer_ary: answer_ary
        },
        (retval) ->
          console.log retval
      )
    $("html, body").animate({ scrollTop: 0 }, "slow")
    false
