#= require 'utility/ajax'
#= require "./_templates/class_list_item"
#= require highcharts

$ ->

  analyze = (dom, target, qid, analyze_type, class_id) ->
    $.getJSON "/teacher/questions/#{qid}/stat?analyze_type=#{analyze_type}&class_id=#{class_id}&target=#{target}", (data) ->
      if data.success
        # refresh the data in the dom
        if analyze_type == "single" && target != "summary"
          dom.find(".result-figure").highcharts
            chart:
              type: "column"
              height: 250
            title:
              text: null
            xAxis:
              categories: data.categories
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
                data: data.data
              }
            ]
            plotOptions:
              series:
                point:
                  events:
                    click: ->
                      dom.find(".result-text p").text("选择\"" + data.categories[@x] + "\"的同学：" + data.students[@x])
      else
        $.page_notification "服务器出错"

  $(".tag-result").each ->
    dom = $(this)
    qid = $(this).closest(".stat-div").attr("data-questionId")
    analyze(dom, "tag", qid, "single", "-1")
    $(this).closest(".result-part").find(".loading").addClass("hide")
    $(this).removeClass("hide")

  $(".question-content-wrapper").each ->
    if $(this).height() > $(this).find(".question-content-div").height()
      $(this).find(".expand-link").addClass("hide")

  $(".expand-link").click (event) ->
    if $(this).attr("data-expand") == "false"
      $(this).closest(".question-content-wrapper").height("auto")
      $(this).attr("data-expand", true)
      $(this).text("收起")
    else
      $(this).closest(".question-content-wrapper").height("60px")
      $(this).attr("data-expand", false)
      $(this).text("展开")

  $("body").on "click", ".inactive-tab", (event) ->
    target = $(event.target).closest(".inactive-tab")
    target.closest(".tab-title").find(".active-tab").removeClass("active-tab").addClass("inactive-tab")
    target.removeClass("inactive-tab").addClass("active-tab")
    switch_analyze_result(target, target.closest(".stat-div").find(".analyze-result"))

  switch_analyze_result = (tab, analyze_result) ->
    analyze_result.find(".filter-part").find(".filter").addClass("hide")
    if tab.hasClass("tag-tab")
      analyze_result.find(".tag-filter").removeClass("hide")
    else if tab.hasClass("topic-tab")
      analyze_result.find(".topic-filter").removeClass("hide")
    else if tab.hasClass("summary-tab")
      analyze_result.find(".summary-filter").removeClass("hide")

  $(".btn-add").click ->
    list = $(this).closest(".compare-analyze").find(".compare-list")
    id = $(this).closest(".compare-analyze").find(".classes").val()
    if list.find('*[data-id="' + id + '"]').length > 0
      return
    item_data =
      id: $(this).closest(".compare-analyze").find(".classes").val()
      name: $(this).closest(".compare-analyze").find(".classes").text()
    item = $(HandlebarsTemplates["class_list_item"](item_data))
    list.append(item)

  $("body").on "click", ".closeicon", (event) ->
    $(event.target).closest("li").remove()
