#= require 'utility/ajax'
#= require jquery.qtip
#= require highcharts
$(document).ready ->

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

  # about change question
  $(".replace-btn").click ->
    qid =  $(this).data("qid")
    console.log qid
    $('#replaceModal form').attr('action', "/teacher/questions/" + qid + "/replace")
    $('#replaceModal .question-download-url').attr('href', "/teacher/questions/" + qid)
    $("#replaceModal").modal "show"
    false

  # about insert question
  $(".insert-btn").click ->
    qid =  $(this).data("qid")
    console.log qid
    $('#insertModal form').attr('action', "/teacher/questions/" + qid + "/insert")
    $("#insertModal").modal "show"
    false

  # about stat modal
  $(".stat-btn").click ->
    qid = $(this).data("qid")
    $("#statModal").modal("show")
    window.current_stat = $(this).closest(".content-div")
    window.current_stat.addClass("current-stat")
    $("#statModal #note-type-text p").text("")
    $("#note-type-fig div").remove()
    $("#statModal #note-topic-text p").text("")
    $("#note-topic-fig div").remove()
    $("#note-summary textarea").text("")
    $.getJSON "/teacher/questions/" + qid + "/stat", (retval) ->
      console.log retval
      $("#note-type-fig").highcharts
        chart:
          type: "column"
          height: 250
        title:
          text: null
        xAxis:
          categories: retval.note_type_ary
        yAxis:
          min: 0
          title:
            text: null
        credits:
          enabled: false
        tooltip:
          headerFormat: "<span style=\"font-size:10px\">{point.key}</span><table>"
          pointFormat: "<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"padding:0\"><b>{point.y:0f}</b></td></tr>"
          footerFormat: "</table>"
          shared: true
          useHTML: true
        series: [
          {
            name: "选择人数"
            data: retval.note_type_data
          }
        ]
        plotOptions:
          series:
            point:
              events:
                click: ->
                  $("#note-type-text p").text("选择\"" + retval.note_type_ary[@x] + "\"的同学：" + retval.note_type[@x])
      $("#note-topic-fig").highcharts
        chart:
          type: "column"
          height: 250
        title:
          text: null
        xAxis:
          categories: retval.note_topic_ary
        yAxis:
          min: 0
          title:
            text: null
        credits:
          enabled: false
        tooltip:
          headerFormat: "<span style=\"font-size:10px\">{point.key}</span><table>"
          pointFormat: "<tr><td style=\"color:{series.color};padding:0\">{series.name}: </td>" + "<td style=\"padding:0\"><b>{point.y:0f}</b></td></tr>"
          footerFormat: "</table>"
          shared: true
          useHTML: true
        series: [
          {
            name: "选择人数"
            data: retval.note_topic_data
          }
        ]
        plotOptions:
          series:
            point:
              events:
                click: ->
                  $("#note-topic-text p").text("选择\"" + retval.note_topic_ary[@x] + "\"的同学：" + retval.note_topic[@x])
      $("#note-summary textarea").text(retval.summary)

  $("#statModal").on "hide.bs.modal", ->
    window.current_stat.removeClass("current-stat")
