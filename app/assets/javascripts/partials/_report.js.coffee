#= require highcharts
$ ->

  $.getJSON "/weixin/lessons/#{window.lesson_id}/time_dist?student_id=#{window.student_id}", (data) ->
    if data.success
      $("#time-dist-figure").highcharts
        chart:
          type: "column"
        title:
          text: null
        series: [{
          name: "时长占比"
          type: 'pie'
          data: data.data
        }]
        credits:
          enabled: false
        tooltip: {
          pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        }
        plotOptions:
          pie:
            cursor: 'pointer'
            dataLabels:
              enabled: true
              color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
              format: '{point.percentage:.1f}%'
            showInLegend: true
    else
      $.page_notification "服务器出错"

  $.getJSON "/weixin/lessons/#{window.lesson_id}/video_dist?student_id=#{window.student_id}", (data) ->
    if data.success
      $("#video-dist-figure").highcharts
        chart:
          type: "pie"
        title:
          text: null
        series: [{
          name: "时长占比"
          type: 'pie'
          data: data.data
        }]
        credits:
          enabled: false
        tooltip: {
          pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        }
        plotOptions:
          pie:
            cursor: 'pointer'
            dataLabels:
              enabled: true
              color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
              format: '{point.percentage:.1f}%'
            showInLegend: true
    else
      $.page_notification "服务器出错"


