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
        console.log retval
        if !retval.success && retval.reason == "require sign in"
          $('#sign').modal({
            show: 'false'
          });
        else
          $this.attr("disabled", true)
          $this.html("已加入错题本")
    )
    false

  $("form#sign_in_user").bind "ajax:success", (e, data, status, xhr) ->
    if data.success
      console.log($("#user_email").val())
      # hide the sign modal
      $('#sign').modal('hide')
      # append the question to the note
      $.postJSON(
        '/user/questions/' + $("#append_note").data("question-id") + '/append_note',
        { },
        (retval) ->
          $("#append_note").attr("disabled", true)
          $("#append_note").html("已加入错题本")
      )
      # change the navbar to show the user's email
      # show the notification
      $("#app-notification").notification({content: "已加入错题本"})
    else
      $("#sign-notification").notification({content: "邮箱或密码错误"})
      