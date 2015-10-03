#= require highcharts
$ ->

  $.getJSON "/weixin/lessons/#{window.lesson_id}/time_dist", (data) ->
    if data.success
      $("#time-dist-figure").highcharts
        chart:
          type: "pie"
        title:
          text: null
        series: [{
          type: 'pie'
          data: data.data
        }]
        credits:
          enabled: false
        plotOptions:
          pie:
            cursor: 'pointer'
            dataLabels:
              enabled: true
              color: '#000000'
              connectorColor: '#000000'
              format: '<b>{point.name}</b>: {point.percentage:.1f} %'
    else
      $.page_notification "服务器出错"


