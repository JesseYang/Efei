class TopicsController < ApplicationController
  def index
    render json: [{label: 'a', value: 'aa'}, {label: 'b', value: 'bb'}, {label: 'c', value: 'cc'}]
  end
end
