# encoding: utf-8
class Weixin::RecordsController < Weixin::ApplicationController

  def index
    data = [
      {
        title: "",
        start: "2015-05-12",
        rendering: "background"
      },
      {
        title: "",
        start: "2015-05-25",
        rendering: "background"
      }
    ]
    render json: data and return
  end

  def show
    @title = "学习记录"
    @local_course = LocalCourse.find(params[:local_course_id])
    @return_path = record_weixin_course_path(@local_course)
    @date = params[:id]
  end
end
