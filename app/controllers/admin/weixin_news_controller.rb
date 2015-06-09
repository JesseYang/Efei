#encoding: utf-8
class Admin::WeixinNewsController < Admin::ApplicationController

  def index
    @weixin_news = auto_paginate WeixinNews.all.desc(:created_at)
  end

  def create
    # save the avatar file
    weixin_news_media = WeixinNewsMedia.new
    weixin_news_media.weixin_news_media = params[:weixin_news_media]
    filetype = "png"
    weixin_news_media.store_weixin_news_media!
    filepath = weixin_news_media.weixin_news_media.file.file
    pic_url = "/weixin_news/" + filepath.split("/")[-1]

    @weixin_news = WeixinNews.create(title: params[:weixin_news]["title"],
      desc: params[:weixin_news]["desc"],
      type: params[:weixin_news]["type"],
      url: params[:weixin_news]["url"],
      pic_url: pic_url)
    redirect_to action: :index and return
  end

  def update
    @weixin_news = WeixinNews.find(params[:id])
    @weixin_news.title = params[:weixin_news]["title"]
    @weixin_news.type = params[:weixin_news]["type"]
    @weixin_news.desc = params[:weixin_news]["desc"]
    @weixin_news.url = params[:weixin_news]["url"]

    if params[:weixin_news_media].present?
      weixin_news_media = WeixinNewsMedia.new
      weixin_news_media.weixin_news_media = params[:weixin_news_media]
      filetype = "png"
      weixin_news_media.store_weixin_news_media!
      filepath = weixin_news_media.weixin_news_media.file.file
      pic_url = "/weixin_news/" + filepath.split("/")[-1]
      @weixin_news.pic_url = pic_url
    end

    @weixin_news.save

    redirect_to action: :index and return
  end

  def destroy
    @weixin_news = WeixinNews.find(params[:id])
    @weixin_news.destroy
    redirect_to action: :index and return
  end

  def toggle_active
    @news = WeixinNews.find(params[:id])
    @news.active = @news.active ? false : true
    @news.save
    redirect_to action: :index and return
  end
end
