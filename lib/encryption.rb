module Encryption

  def self.encrypt_password(string)
    key = EzCrypto::Key.with_password("password", "efei")
    return Base64.encode64(key.encrypt(string.to_s).to_s)
  end

  def self.decrypt_password(string)
    key = EzCrypto::Key.with_password("password", "efei")
    return key.decrypt(Base64.decode64(string.to_s).to_s)
  end

  def self.encrypt_auth_key(string)
    key = EzCrypto::Key.with_password("auth_key", "efei")
    return Base64.urlsafe_encode64(key.encrypt(string.to_s).to_s)
  end

  def self.decrypt_auth_key(string)
    key = EzCrypto::Key.with_password("auth_key", "efei")
    begin
      return key.decrypt(Base64.urlsafe_decode64(string.to_s).to_s)
    rescue
      return ""
    end
  end

  def self.encrypt_activate_key(string)
    key = EzCrypto::Key.with_password("activate_key", "efei")
    return Base64.urlsafe_encode64(key.encrypt(string.to_s).to_s)
  end

  def self.decrypt_activate_key(string)
    key = EzCrypto::Key.with_password("activate_key", "efei")
    return key.decrypt(Base64.urlsafe_decode64(string.to_s).to_s)
  end

end
