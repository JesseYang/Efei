# encoding: utf-8
module UserComponents::Client
  extend ActiveSupport::Concern

  included do
    field :is_client, type: Boolean, default: false
    field :client_name, type: String, default: ""
    field :city, type: String, default: ""

    has_many :client_weixin_bind, class_name: "WeixinBind", inverse_of: :client

    has_many :client_coaches, class_name: "User", inverse_of: :coach_client
    has_many :client_students, class_name: "User", inverse_of: :student_client
    has_many :client_courses, class_name: "Course", inverse_of: :client
  end

  module ClassMethods
    def create_client(client)
      return ErrCode::CLIENT_NAME_EXIST if User.where(client_name: client["client_name"]).present?
      return ErrCode::EMAIL_EXIST if User.where(email: client["email"]).present?
      return ErrCode::MOBILE_EXIST if User.where(mobile: client["mobile"]).present?
      client = User.create({
        client_name: client["client_name"],
        password: Encryption.encrypt_password(client["password"]),
        name: client["name"],
        email: client["email"],
        mobile: client["mobile"],
        city: client["city"],
        is_client: true
      })
    end
  end

  def update_client(client)
    self.update_attributes({
      name: client["name"],
      email: client["email"],
      mobile: client["mobile"],
      city: client["city"],
      client_name: client["client_name"]
    })
    if client["password"].present?
      self.update_attributes({
        password: Encryption.encrypt_password(client["password"])
      })
    end
    true
  end
end
