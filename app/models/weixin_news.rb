# encoding: utf-8
class WeixinNews
  include Mongoid::Document
  include Mongoid::Timestamps

  @@media_folder = "public/weixin_news/"

  field :active, type: Boolean, default: false
  field :title, type: String, default: ""
  field :type, type: String, default: ""
  field :desc, type: String, default: ""
  field :pic_url, type: String, default: ""
  field :url, type: String, default: ""

  def self.type_info(type)
    {
      "MSWK" => "名师微课",
      "ZCKD" => "政策快递",
      "JYZT" => "经验之谈"
    } [type]
  end

  def self.type_for_select
    {
      "名师微课" => "MSWK",
      "政策快递" => "ZCKD",
      "经验之谈" => "JYZT"
    }
  end
end
