#= require 'moment.min'
#= require "fullcalendar"
#= require "lang-all"
$ ->
  $("#calendar").fullCalendar({
    defaultView: 'agendaDay'
    minTime: '08:00:00'
    maxTime: '22:00:00'
    allDaySlot: false
    defaultDate: window.date
    lang: "zh-cn"
    events: "/weixin/schedules/data?date=#{window.date}"
    header: {
      left:   'title',
      center: '',
      right:  'prev,next'
    }
  })
