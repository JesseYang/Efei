# encoding: utf-8
require 'redis'
class Weixin

  WEIXIN_SERVER = "https://api.weixin.qq.com/cgi-bin/token"
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
    url = WEIXIN_SERVER + 
      "?grant_type=client_credential&appid=" + APPID +
      "&secret=" + SECRET
    response = HTTParty.get(url)
    if response["errcode"].blank?
      @@redis.set("weixin_access_token", response["access_token"])
      @@redis.set("weixin_access_token_expires_at", Time.now.to_i + response["expires_in"] - 200)
    end
    response["access_token"]
  end

end
