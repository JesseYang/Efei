#encoding: utf-8
class MailgunApi

  @@test_email = "test@efei.org"
  @@email_from = "\"易飞网\" <postmaster@efei.org>"
  @@email_domain = "efei.org"

  def self.reset_email(user, email)
    @user = user
    @email = email
    reset_email_info = "#{user.id.to_s},#{email},#{Time.now.to_i}"
    @reset_email_link = "#{Rails.application.config.server_host}/account/registrations/reset_email?key=" + CGI::escape(Encryption.encrypt_reset_email_key(reset_email_info))
    data = {}
    data[:domain] = @@email_domain
    data[:from] = @@email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/reset_email.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/reset_email.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template.result(binding), :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:subject] = "修改登录邮箱"
    data[:subject] += " --- to #{user.email}" if Rails.env != "production"
    data[:to] = Rails.env == "production" ? email : @@test_email
    self.send_message(data)
  end

  def self.forget_password(uid)
    @user = User.find(uid)
    password_info = "#{@user.email},#{Time.now.to_i}"
    @password_link = "#{Rails.application.config.server_host}/account/passwords/edit?key=" + CGI::escape(Encryption.encrypt_activate_key(password_info))
    data = {}
    data[:domain] = @@email_domain
    data[:from] = @@email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/find_password_email.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/find_password_email.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template_file_name, :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:subject] = "找回密码"
    data[:subject] += " --- to #{@user.email}" if Rails.env != "production"
    data[:to] = Rails.env == "production" ? @user.email : @@test_email
    self.send_message(data)
  end

  def self.export_note(email, attachment)
    data = {}
    data[:domain] = @@email_domain
    data[:from] = @@email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/export_note.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/export_note.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template_file_name, :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:attachment] = File.new(attachment)
    data[:subject] = "题目导出<易飞网>"
    data[:subject] += " --- to #{email}" if Rails.env != "production" 
    data[:to] = Rails.env == "production" ? email : @@test_email
    data[:to] = email
    self.send_message(data)
  end

  def self.send_message(data)
    # domain = data.delete(:domain)
    domain = data[:domain]
    begin
      Rails.logger.info data.inspect
      retval = RestClient.post("https://api:#{Rails.application.config.mailgun_api_key}"\
        "@api.mailgun.net/v2/#{domain}/messages", data)
      Rails.logger.info retval.inspect
      retval = JSON.parse(retval)
      return retval["id"]
    rescue
      return -1
    end
  end
end
