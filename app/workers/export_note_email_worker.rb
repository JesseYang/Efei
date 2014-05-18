class ExportNoteEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "efei_#{Rails.env}".to_sym

  def perform(email, attachment)
    MailgunApi.export_note(email, attachment)
    return true
  end
end
