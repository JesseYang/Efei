# encoding: utf-8
class InviteCode
  include Mongoid::Document
  include Mongoid::Timestamps

  field :code, type: String
  field :used, type: Boolean, default: false

  def self.generate(amount)
    amount.to_i.times do
      code = (0..5).to_a.map { (('0'..'9').to_a + ('a'..'z').to_a)[(rand * 36).to_i] } .join
      i = InviteCode.create(code: code, used: false)
    end
  end
end
