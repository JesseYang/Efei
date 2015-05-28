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
end
