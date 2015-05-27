# encoding: utf-8
class Weixin::CoursesController < Weixin::ApplicationController

  def index
    @current = params[:current] || 1
    @subject = params[:subject] || 0
    @title = @current.to_i == 1 ? "我的当前课程" : "我的历史课程"
    if @subject.to_i != 0
      @title += "(#{Subject::NAME[@subject.to_i]})"
    end

    @courses = Course.all
    # @courses = []
    # c = Course.new(subject: 2, name: "高中必修1同步精讲")
    # @courses << c
  end

  def exercise
    @course = Course.find(params[:id])
    @title = "练习反馈"
  end

  def report
    @course = Course.find(params[:id])
    @title = "学情报告"
  end

  def record
    @course = Course.find(params[:id])
    @title = "学习记录"
  end

  def schedule
    @course = Course.find(params[:id])
    @title = "进度追踪"
  end
end
