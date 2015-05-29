#= require "jweixin-1.0.0"
#= require "utility/ajax"
#= require "layouts/coach-layout"
$ ->
  authorize(["chooseImage", "previewImage"])

  $("a").click ->
    wx.chooseImage
      success: (res) ->
        localIds = res.localIds # 返回选定照片的本地ID列表，localId可以作为img标签的src属性显示图片
