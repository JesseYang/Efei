$ ->
  $(".admin-nav .news").addClass("active")

  $(".edit-news").click ->
    $("#editWeixinNews").modal("show")
    $("#editWeixinNews form").attr("action", "/admin/weixin_news/" + $(this).closest("tr").attr("data-id"))
    $("#editWeixinNews #weixin_news_title").val($(this).closest("tr").find(".title-td").text())
    $("#editWeixinNews #weixin_news_desc").val($(this).closest("tr").find(".desc-td").text())
    $("#editWeixinNews #weixin_news_url").val($(this).closest("tr").find(".url-td").text())

