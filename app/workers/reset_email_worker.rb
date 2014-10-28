class ResetEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "efei_#{Rails.env}".to_sym

  def perform(user, email)
    MailgunApi.reset_email_password(user, email)
    return true
  end
end
