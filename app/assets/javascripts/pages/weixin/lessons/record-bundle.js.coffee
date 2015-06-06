#= require highcharts
$ ->
  $("#lesson-time-figure").highcharts
    chart:
      type: "pie"
    title:
      text: null
    series: [{
      type: 'pie'
      data: [
          ['第一讲', 45.0]
          ['第二讲', 26.8]
          ['其他', 10.0]
      ]
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

  $("#type-time-figure").highcharts
    chart:
      type: "pie"
    title:
      text: null
    series: [{
      type: 'pie'
      data: [
          ['听见', 45.0]
          ['做例题', 26.8]
          ['做练习', 10.0]
      ]
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

