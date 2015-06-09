$ ->
  $(".admin-nav .coaches").addClass("active")

  $(".edit-coach").click ->
    $("#editCoach").modal("show")
    $("#editCoach form").attr("action", "/admin/coaches/" + $(this).closest("tr").attr("data-id"))
    $("#editCoach #coach_name").val($(this).closest("tr").find(".name-td").text())
    $("#editCoach #coach_coach_number").val($(this).closest("tr").find(".coach-number-td").text())
    $("#editCoach #coach_email").val($(this).closest("tr").find(".email-td").text())
    $("#editCoach #coach_mobile").val($(this).closest("tr").find(".mobile-td").text())

  $("#newCoach form").submit ->
    if $.trim($("#newCoach #coach_name").val()) == ""
      $.page_notification("请填写姓名")
      return false
    if $.trim($("#newCoach #coach_coach_number").val()) == ""
      $.page_notification("请填写员工号")
      return false
    if $.trim($("#newCoach #coach_password").val()) == ""
      $.page_notification("请填写密码")
      return false
    if $.trim($("#newCoach #coach_email").val()) == ""
      $.page_notification("请填写邮箱")
      return false
    if $.trim($("#newCoach #coach_mobile").val()) == ""
      $.page_notification("请填写手机")
      return false

  $("#editCoach form").submit ->
    if $.trim($("#editCoach #coach_name").val()) == ""
      $.page_notification("请填写姓名")
      return false
    if $.trim($("#editCoach #coach_coach_number").val()) == ""
      $.page_notification("请填写员工号")
      return false
    if $.trim($("#editCoach #coach_email").val()) == ""
      $.page_notification("请填写邮箱")
      return false
    if $.trim($("#editCoach #coach_mobile").val()) == ""
      $.page_notification("请填写手机")
      return false
