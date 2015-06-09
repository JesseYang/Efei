# encoding: utf-8
class Weixin::SchedulesController < Weixin::ApplicationController
  skip_before_filter :weixin_init, only: :redirect

  def redirect
    redirect_to Weixin.generate_authorize_link(Rails.application.config.server_host + "/weixin/schedules") and return
  end

  def index
    @title = "我的课表"
    @local_courses = @current_user.student_local_courses
    if params[:local_course_id].present?
      @local_course = LocalCourse.find(params[:local_course_id])
    end
  end

  def show
    @date = params[:id]
    @title = "我的课表"
    @return_path = weixin_schedules_path
  end

  # get the dates that have lessons
  def data
    if params[:date].present?
      data = [ ]
      @current_user.student_local_courses.each do |lc|
        lc.time_ary.each do |time|
          data.push({
            "title" => lc.desc,
            "start" => Time.at(time["start_time"]).iso8601,
            "end" => Time.at(time["end_time"]).iso8601
          })
        end
      end
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
