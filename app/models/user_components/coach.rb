# encoding: utf-8
module UserComponents::Coach
  extend ActiveSupport::Concern

  included do
    field :coach, type: Boolean, default: false
    field :coach_number, type: String, default: ""

    has_many :coach_weixin_bind, class_name: "WeixinBind", inverse_of: :coach

    has_and_belongs_to_many :students, class_name: "User", inverse_of: :coaches

  end

  module ClassMethods
    def create_coach(coach)
      return ErrCode::COACH_NUMBER_EXIST if User.where(coach_number: coach["coach_number"]).present?
      return ErrCode::EMAIL_EXIST if User.where(email: coach["email"]).present?
      return ErrCode::MOBILE_EXIST if User.where(mobile: coach["mobile"]).present?
      coach = User.create({
        name: coach["name"],
        coach_number: coach["coach_number"],
        password: Encryption.encrypt_password(coach["password"]),
        email: coach["email"],
        mobile: coach["mobile"],
        coach: true
      })
    end

    def coaches_for_select
      hash = { "请选择" => -1 }
      User.where(coach: true).each do |t|
        hash[t.name] = t.id.to_s
      end
      hash
    end
  end

  def update_coach(coach)
    return ErrCode::COACH_NUMBER_EXIST if User.where(coach_number: coach["coach_number"]).present?
    return ErrCode::EMAIL_EXIST if User.where(email: coach["email"]).present?
    return ErrCode::MOBILE_EXIST if User.where(mobile: coach["mobile"]).present?
    self.name = coach["name"]
    self.coach_number = coach["coach_number"]
    self.email = coach["email"]
    self.mobile = coach["mobile"]
    if coach["password"].present?
      self.password = Encryption.encrypt_password(coach["password"])
    end
    self.save
  end
end
