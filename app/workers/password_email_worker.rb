class PasswordEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "efei_#{Rails.env}".to_sym

  def perform(user)
    MailgunApi.forget_password(user)
    return true
  end
end
