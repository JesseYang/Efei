class TopicsController < ApplicationController
  def index
    @topics = Topic.where(user_create: false, subject: params[:subject].to_i)
    @topics = @topics.any_of({name: /#{params[:term]}/}, {pinyin: /#{params[:term]}/})
    @topics = @topics.map { |e| {label: e.name, name: e.name} }
    render json: @topics and return
  end
end
