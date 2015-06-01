# encoding: utf-8
require 'redis'
require 'httparty'
class Weixin

  include HTTParty
  base_uri "https://api.weixin.qq.com"
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
    url = "/cgi-bin/token?grant_type=client_credential&appid=#{APPID}&secret=#{SECRET}"
    response = Weixin.get(url)
    if response["errcode"].blank?
      @@redis.set("weixin_access_token", response["access_token"])
      @@redis.set("weixin_access_token_expires_at", Time.now.to_i + response["expires_in"] - 100)
    end
    response["access_token"]
  end

  def self.get_jsapi_ticket
    @@redis ||= Redis.new
    expires_at = @@redis.get("weixin_jsapi_ticket_expires_at").to_i
    if expires_at > Time.now.to_i
      @@redis.get("weixin_jsapi_ticket")
    else
      self.refresh_jsapi_ticket
    end
  end

  def self.refresh_jsapi_ticket
    @@redis ||= Redis.new
    url = "/cgi-bin/ticket/getticket?access_token=#{self.get_access_token}&type=jsapi"
    response = Weixin.get(url)
    if response["errcode"].blank? || response["errcode"].to_s == "0"
      @@redis.set("weixin_jsapi_ticket", response["ticket"])
      @@redis.set("weixin_jsapi_ticket_expires_at", Time.now.to_i + response["expires_in"] - 100)
    end
    response["ticket"]
  end

  def self.generate_authorize_link(callback_url, with_info = false)
    scope = with_info ? "snsapi_userinfo" : "snsapi_base"
    encode_url = CGI.escape(callback_url)
    url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{APPID}&redirect_uri=#{encode_url}&response_type=code&scope=#{scope}#wechat_redirect"
    url
  end

  def self.get_oauth_open_id(code)
    url = "/sns/oauth2/access_token?appid=#{APPID}&secret=#{SECRET}&code=#{code}&grant_type=authorization_code"
    response = Weixin.get(url)
    response["openid"]
  end

  def self.get_oauth_open_id_and_user_info(code)
    url = "/sns/oauth2/access_token?appid=#{APPID}&secret=#{SECRET}&code=#{code}&grant_type=authorization_code"
    response = Weixin.get(url)
    open_id = response["openid"]

    url = "/sns/userinfo?access_token=#{response["access_token"]}&openid=#{response["openid"]}&lang=zh_CN"
    response = Weixin.get(url)
    {
      open_id: open_id,
      nickname: response["nickname"]
    }
  end

  def self.update_menu
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
              "url" => "http://efei.org/weixin/courses/redirect"
            },
            {
              "type" => "view", 
              "name" => "我的学生", 
              "url" => "http://efei.org/coach/students/redirect"
            },
=begin
            {
              "type" => "click", 
              "name" => "作业反馈", 
              "key" => "ZYFK"
            },
=end
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

    response = Weixin.post("/cgi-bin/menu/create?access_token=#{self.get_access_token}",
      :body => data.to_json)
    return response.body
  end

end
