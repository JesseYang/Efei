#= require 'utility/ajax'
#= require "./_templates/class_list_item"
#= require "./_templates/summary_result"
#= require highcharts

$ ->

  analyze = (dom, target, qid, analyze_type, class_id) ->
    note_text = 
      summary: "总结"
      tag: "标签"
      topic: "知识点"
    $.getJSON "/teacher/questions/#{qid}/stat?analyze_type=#{analyze_type}&class_id=#{class_id}&target=#{target}", (data) ->
      if data.success
        # refresh the data in the dom
        if target == "summary"
          if data.summary.length == 0
            dom.find(".no-result-tip").removeClass("hide")
            dom.find(".no-result-tip span").text("没有学生对这道题目添加" + note_text[target])
            dom.find(".summary-content").empty()
          else
            summary_result = $(HandlebarsTemplates["summary_result"](data))
            dom.find(".no-result-tip").addClass("hide")
            dom.find(".summary-content").empty()
            dom.find(".summary-content").append(summary_result)
        else if analyze_type == "single"
          if data.categories.length == 0
            dom.find(".no-result-tip").removeClass("hide")
            dom.find(".no-result-tip span").text("没有学生对这道题目添加" + note_text[target])
            dom.find(".result-figure").empty()
          else
            dom.find(".no-result-tip").addClass("hide")
            dom.find(".result-figure").highcharts
              chart:
                type: "column"
                height: 250
                width: 498
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
              series: data.series
              plotOptions:
                series:
                  point:
                    events:
                      click: ->
                        dom.find(".result-text p").text("选择\"" + data.categories[@x] + "\"的同学：" + data.students[@x])
        else if analyze_type == "compare"
          dom.find(".result-figure").highcharts
            chart:
              type: "column"
              height: 250
              width: 498
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
            series: data.series
            plotOptions:
              series:
                point:
                  events:
                    click: ->
                      dom.find(".result-text p").text("选择\"" + data.categories[@x] + "\"的同学：" + data.students[@x])
        dom.closest(".result-part").find(".loading").addClass("hide")
        dom.closest(".result-part").find(".no-target").addClass("hide")
        dom.removeClass("hide")
      else
        $.page_notification "服务器出错"

  refresh_data = (target, dom) ->
    stat_div = dom.closest(".stat-div")
    qid = stat_div.attr("data-questionId")
    class_id = ""
    class_id_ary = [ ]
    if target == "tag"
      dom = stat_div.find(".tag-result")
      active_li = stat_div.find(".tag-filter li.active")
      analyze_type = if active_li.hasClass("single-li") then "single" else "compare"
      if analyze_type == "single"
        class_id = stat_div.find(".tag-filter .single-analyze select").val()
      else
        stat_div.find(".tag-filter .compare-analyze li").each ->
          class_id_ary.push $(this).attr("data-id")
        class_id = class_id_ary.join(",")
    else if target == "topic"
      dom = stat_div.find(".topic-result")
      active_li = stat_div.find(".topic-filter li.active")
      analyze_type = if active_li.hasClass("single-li") then "single" else "compare"
      if analyze_type == "single"
        class_id = stat_div.find(".topic-filter .single-analyze select").val()
      else
        stat_div.find(".topic-filter .compare-analyze li").each ->
          class_id_ary.push $(this).attr("data-id")
        class_id = class_id_ary.join(",")
    else if target == "summary"
      dom = stat_div.find(".summary-result")
      class_id = stat_div.find(".summary-filter select").val()
    stat_div.find(".result-part .tag-result").addClass("hide")
    stat_div.find(".result-part .topic-result").addClass("hide")
    stat_div.find(".result-part .summary-result").addClass("hide")
    if analyze_type == "compare" && class_id == ""
      stat_div.find(".result-part .no-target").removeClass("hide")
      stat_div.find(".result-part .loading").addClass("hide")
      return
    else
      stat_div.find(".result-part .loading").removeClass("hide")
      stat_div.find(".result-part .no-target").addClass("hide")
    analyze(dom, target, qid, analyze_type, class_id)

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
      refresh_data("tag", tab)
    else if tab.hasClass("topic-tab")
      analyze_result.find(".topic-filter").removeClass("hide")
      refresh_data("topic", tab)
    else if tab.hasClass("summary-tab")
      analyze_result.find(".summary-filter").removeClass("hide")
      refresh_data("summary", tab)

  $(".btn-add").click ->
    list = $(this).closest(".compare-analyze").find(".compare-list")
    id = $(this).closest(".compare-analyze").find(".classes").val()
    if list.find('*[data-id="' + id + '"]').length > 0
      return
    item_data =
      id: $(this).closest(".compare-analyze").find(".classes option:selected").val()
      name: $(this).closest(".compare-analyze").find(".classes option:selected").text()
    item = $(HandlebarsTemplates["class_list_item"](item_data))
    list.append(item)
    if $(this).closest(".filter").hasClass("topic-filter")
      refresh_data("topic", $(this))
    else
      refresh_data("tag", $(this))

  $("body").on "click", ".closeicon", (event) ->
    filter = $(event.target).closest(".filter")
    $(event.target).closest("li").remove()
    if filter.hasClass("topic-filter")
      refresh_data("topic", filter)
    else
      refresh_data("tag", filter)

  $(".summary-filter select").change ->
    refresh_data("summary", $(this))

  $(".topic-filter .single-analyze select").change ->
    refresh_data("topic", $(this))

  $(".tag-filter .single-analyze select").change ->
    refresh_data("tag", $(this))

  $(".tag-filter a[data-toggle=pill]").on "shown.bs.tab", (event) ->
    refresh_data("tag", $(event.target))

  $(".topic-filter a[data-toggle=pill]").on "shown.bs.tab", (event) ->
    refresh_data("topic", $(event.target))
