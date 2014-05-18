#encoding: utf-8
class MailgunApi

  @@test_email = "test@b-fox.cn"
  @@email_from = "\"易飞网\" <postmaster@b-fox.cn>"
  @@email_domain = "b-fox.cn"

  def self.export_note(email, attachment)
    data = {}
    data[:domain] = @@email_domain
    data[:from] = @@email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/export_note.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/export_note.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template.result(binding), :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:attachment] = File.new(attachment)
    data[:subject] = "错题本导出<易飞网>"
    # data[:subject] += " --- to #{user.email}" if Rails.env != "production" 
    # data[:to] = Rails.env == "production" ? email : @@test_email
    data[:to] = email
    self.send_message(data)
  end

  def self.send_message(data)
    Rails.logger.info "AAAAAAAAAAAAAAA"
    # domain = data.delete(:domain)
    domain = data[:domain]
      Rails.logger.info data.inspect
      Rails.logger.info "BBBBBBBBBBBBBBBB"
      retval = RestClient.post("https://api:#{Rails.application.config.mailgun_api_key}"\
        "@api.mailgun.net/v2/#{domain}/messages", data)
      Rails.logger.info retval.inspect
      retval = JSON.parse(retval)
      return retval["id"]
      Rails.logger.info "CCCCCCCCCCCCCCCC"
  end
end
