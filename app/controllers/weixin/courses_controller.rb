# encoding: utf-8
class Weixin::CoursesController < Weixin::ApplicationController

  def index
    @title = "我的当前课程"
    # @courses = Course.all
    @courses = []
    c = Course.new(subject: 2, name: "高中必修1同步精讲")
    @courses << c
  end
end
