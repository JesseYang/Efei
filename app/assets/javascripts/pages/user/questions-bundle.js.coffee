//= require 'utility/ajax'
$ ->
  $("#check_questions").click ->
    $.get(
      '/user/questions/' + $(this).data("question-id") + '/similar',
      { },
      (retval) ->
        $(".page-operation-div").addClass("hide")
        $(".question-operation-div").removeClass("hide")
        $("#similar-questions-div").html(retval)
        $("#similar-questions-div").slideDown()
    )
    false

  $("#append_note").click ->
    $this = $(this)
    $.postJSON(
      '/user/questions/' + $(this).data("question-id") + '/append_note',
      { },
      (retval) ->
        if !retval.success && retval.reason == "require sign in"
          window.location = "/users/sign_in"
        console.log retval
        $this.attr("disabled", true)
        $this.html("已加入错题本")
    )
    false
