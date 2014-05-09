$ ->

  $(".tooltips").hover ->
    $(this).tooltip('show')


  $(".wrap h2").dblclick ->
    $(this).addClass("hide")
    $(this).closest(".wrap").find(".title-edit").removeClass("hide")

  $(".title-cancel").click ->
    $(this).closest(".wrap").find(".title-edit").addClass("hide")
    $(this).closest(".wrap").find("h2").removeClass("hide")

  $(".title-ok").click ->
    new_name = $(this).closest(".wrap").find("input").val()
    $this = $(this)
    $.postJSON(
      '/admin/homeworks/' + $(this).data("homework-id") + '/rename',
      {
        name: new_name
      },
      (retval) ->
        $this.closest(".wrap").find("h2").html(new_name)
        $this.closest(".wrap").find(".title-edit").addClass("hide")
        $this.closest(".wrap").find("h2").removeClass("hide")
    )

  $(".title-edit input").keypress (e) ->
    if e.which is 13
      new_name = $(this).val()
      $this = $(this)
      homework_id = $(this).closest(".wrap").find(".title-ok").data("homework-id")
      $.postJSON(
        '/admin/homeworks/' + homework_id + '/rename',
        {
          name: new_name
        },
        (retval) ->
          $this.closest(".wrap").find("h2").html(new_name)
          $this.closest(".wrap").find(".title-edit").addClass("hide")
          $this.closest(".wrap").find("h2").removeClass("hide")
      )