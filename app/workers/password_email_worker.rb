class PasswordEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "efei_#{Rails.env}".to_sym

  def perform(uid)
    MailgunApi.forget_password(uid)
    return true
  end
end
