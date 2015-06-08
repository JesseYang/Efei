#= require 'moment.min'
#= require "fullcalendar"
#= require "lang-all"
$ ->
  $("#calendar").fullCalendar({
    lang: "zh-cn"
    events: "/weixin/schedules/data"
    header: {
      left:   'title',
      center: '',
      right:  'prev,next'
    }
    dayClick: (date, jsEvent, view) ->
      url = "/weixin/schedules/" + date.format()
      window.location.href = url
  })
