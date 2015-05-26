# encoding: utf-8
require 'redis'
require 'httparty'
class Weixin

  include HTTParty
  base_uri "https://api.weixin.qq.com/cgi-bin"
  format  :json

  APPID = "wx70147c2214d04e30"
  SECRET = "432ecf07f2a5359979d6a605280cba32"

  def self.get_access_token
    @@redis ||= Redis.new
    expires_at = @@redis.get("weixin_access_token_expires_at").to_i
    if expires_at > Time.now.to_i
      @@redis.get("weixin_access_token")
    else
      self.refresh_access_token
    end
  end

  def self.refresh_access_token
    @@redis ||= Redis.new
    url = "/token?grant_type=client_credential&appid=#{APPID}&secret=#{SECRET}"
    response = Weixin.get(url)
    if response["errcode"].blank?
      @@redis.set("weixin_access_token", response["access_token"])
      @@redis.set("weixin_access_token_expires_at", Time.now.to_i + response["expires_in"] - 200)
    end
    response["access_token"]
  end

  def self.update_menu
    url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=ACCESS_TOKEN"

    data = {
      "button" => [
        {
          "name" => "易飞好学",
          "sub_button" => [
            {
              "type" => "click", 
              "name" => "名师微课", 
              "key" => "MSWK"
            },
            {
              "type" => "click", 
              "name" => "经验之谈", 
              "key" => "JYZT"
            },
            {
              "type" => "click", 
              "name" => "政策快递", 
              "key" => "ZCKD"
            }
          ]
        },
        {
          "name" => "课程咨询",
          "sub_button" => [
            {
              "type" => "view", 
              "name" => "学习中心", 
              "url" => "http://www.baidu.com"
            },
            {
              "type" => "view", 
              "name" => "课程查询", 
              "url" => "http://www.baidu.com"
            },
            {
              "type" => "view", 
              "name" => "优惠活动", 
              "url" => "http://www.baidu.com"
            },
            {
              "type" => "click", 
              "name" => "联系客服", 
              "key" => "LXKF"
            }
          ]
        },
        {
          "name" => "我的易飞",
          "sub_button" => [
            {
              "type" => "view", 
              "name" => "我的课程", 
              "url" => "http://www.baidu.com"
            },
            {
              "type" => "click", 
              "name" => "作业反馈", 
              "key" => "ZYFK"
            },
            {
              "type" => "click", 
              "name" => "学情报告", 
              "key" => "XQBG"
            },
            {
              "type" => "click", 
              "name" => "学习记录", 
              "key" => "XXJL"
            },
            {
              "type" => "click", 
              "name" => "考勤订阅", 
              "key" => "KQDY"
            }
          ]
        }
      ]
    }

    response = Weixin.post("/menu/create?access_token=#{self.get_access_token}",
      :body => data.to_json)
    binding.pry
    return response.body
  end

end
