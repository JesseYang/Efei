# encoding: utf-8
class Weixin::SchedulesController < Weixin::ApplicationController
  skip_before_filter :weixin_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/schedules") and return
  end

  def index
    @title = "我的课表"
  end

  def show
    date = params[:id]
    @title = date
    @return_path = weixin_schedules_path
  end

  # get the dates that have lessons
  def data
    if params[:date].present?
      data = [{
        title: "高一预习",
        start: "2015-06-20T13:21:58+00:00",
        "end" => "2015-06-20T15:21:58+00:00"
        }]
      render json: data and return
    else
      data = [ ]
      @current_user.student_local_courses.each do |lc|
        lc.time_ary.each do |time|
          data.push({
            title: "",
            start: time["date"],
            rendering: "background"
          })
        end
      end
      render json: data.uniq and return
    end
  end
end
