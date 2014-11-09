# encoding: utf-8
class Student::TopicsController < Student::ApplicationController

  before_filter :require_student

  def index
    topics = Topic.where(user_create: false, subject: params[:subject].to_i)
    render_with_auth_key { topics: topics.map { |e| e.to_ary } }
  end
end
