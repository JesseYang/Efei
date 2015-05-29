#= require 'moment.min'
#= require "fullcalendar"
#= require "lang-all"
$ ->
  $("#calendar").fullCalendar({
    lang: "zh-cn"
    events: "/weixin/records"
    header: {
      left:   'title',
      center: '',
      right:  'prev,next'
    }
    dayClick: (date, jsEvent, view) ->
      url = "/weixin/records/" + date.format() + "?local_course_id=" + window.local_course_id
      window.location.href = url
  })
