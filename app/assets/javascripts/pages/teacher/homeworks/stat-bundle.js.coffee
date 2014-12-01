#= require "./_templates/class_list_item"

$ ->

  $(".expand-link").click (event) ->
    if $(this).attr("data-expand") == "false"
      $(this).closest(".question-content-div").height("auto")
      $(this).attr("data-expand", true)
      $(this).text("收起")
    else
      $(this).closest(".question-content-div").height("60px")
      $(this).attr("data-expand", false)
      $(this).text("展开")

  $("body").on "click", ".inactive-tab", (event) ->
    target = $(event.target).closest(".inactive-tab")
    target.closest(".tab-title").find(".active-tab").removeClass("active-tab").addClass("inactive-tab")
    target.removeClass("inactive-tab").addClass("active-tab")
    refresh_analyze_result(target, target.closest(".stat-div").find(".analyze-result"))

  refresh_analyze_result = (tab, analyze_result) ->
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
