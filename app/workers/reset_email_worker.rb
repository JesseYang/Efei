class ResetEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "efei_#{Rails.env}".to_sym

  def perform(uid, email)
    MailgunApi.reset_email(uid, email)
    return true
  end
end
