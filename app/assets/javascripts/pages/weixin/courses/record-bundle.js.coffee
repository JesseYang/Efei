#= require 'moment.min'
#= require "fullcalendar"
#= require "lang-all"
$ ->
  $("#calendar").fullCalendar({
    lang: "zh-cn"
    events: "/weixin/records"
    # events: [{title: "record", start: "2015-05-25", allDay: "true", rendering: "background"}]
  })
