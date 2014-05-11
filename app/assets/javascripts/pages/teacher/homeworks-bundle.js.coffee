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
      '/teacher/homeworks/' + $(this).data("homework-id") + '/rename',
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
        '/teacher/homeworks/' + homework_id + '/rename',
        {
          name: new_name
        },
        (retval) ->
          $this.closest(".wrap").find("h2").html(new_name)
          $this.closest(".wrap").find(".title-edit").addClass("hide")
          $this.closest(".wrap").find("h2").removeClass("hide")
      )

  # about homework list

  $("#privilege-select").change ->
    select_changed()

  $("#subject-select").change ->
    select_changed()

  select_changed = ->
    privilege = $("#privilege-select").val()
    subject = $("#subject-select").val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject + "&privilege=" + privilege

  $("#btn-search").click ->
    search()
  $("#input-search").keydown (e) ->
    search() if e.which == 13

  search = ->
    privilege = $("#privilege-select").val()
    subject = $("#subject-select").val()
    keyword = $("#input-search").val()
    window.location.href = location.protocol + '//' + location.host + location.pathname + "?subject=" + subject + "&privilege=" + privilege + "&keyword=" + keyword



  # about homework share

  $(".share-all").change ->
    share_all = $(this).is(":checked")
    $(".share-one").each ->
      $(this).prop("checked", share_all)
    $.putJSON(
      "/teacher/homeworks/" + window.homework_id + "/share_all",
      {
        share: share_all
      },
      (retval) ->
    )

  $(".share-one").change ->
    teacher_id = $(this).closest("tr").data("id")
    $this = $(this)
    $.putJSON(
      "/teacher/homeworks/" + window.homework_id + "/share",
      {
        teacher_id: teacher_id,
        share: $this.is(":checked")
      },
      (retval) ->
    )