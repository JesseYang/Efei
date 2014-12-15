#= require 'utility/ajax'
#= require highcharts
$ ->
  $.getJSON "/teacher/students/#{window.student_id}/stat", (data) ->
    if data.success
      $("#tag-stat").highcharts
        chart:
          type: "column"
          height: 300
        title:
          text: "标签分布"
        xAxis:
          categories: data.tag_stat.tag_categories
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
        series: data.tag_stat.tag_series
      $("#topic-stat").highcharts
        chart:
          type: "column"
          height: 300
        title:
          text: "知识点分布"
        xAxis:
          categories: data.topic_stat.topic_categories
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
        series: data.topic_stat.topic_series
    else
      $.page_notification "服务器出错"
