class ExportNoteEmailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 10, :queue => "efei_#{Rails.env}".to_sym

  def perform(attachment)
    MailgunApi.export_note(attachment)
    return true
  end
end
