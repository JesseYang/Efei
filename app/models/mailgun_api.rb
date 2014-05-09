#encoding: utf-8
class MailgunApi

  @@test_email = "test@b-fox.cn"
  @@email_from = "\"易飞网\" <postmaster@b-fox.cn>"
  @@email_domain = "b-fox.cn"

  def self.welcome_email(user, protocol_hostname, callback)
    @user = user
    activate_info = {"email" => user.email, "time" => Time.now.to_i}
    @activate_link = "#{protocol_hostname}#{callback}?key=" + CGI::escape(Encryption.encrypt_activate_key(activate_info.to_json))
    result = MongoidShortener.generate(@activate_link)
    @activate_link = "#{protocol_hostname}/#{result}" if result.present?
    data = {}
    data[:domain] = Rails.application.config.email_domain
    data[:from] = @@email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/welcome_email.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/welcome_email.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template.result(binding), :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:subject] = "欢迎注册易飞网"
    data[:subject] += " --- to #{user.email}" if Rails.env != "production" 
    data[:to] = Rails.env == "production" ? user.email : @@test_email
    self.send_message(data)
  end

  def self.change_email(user, protocol_hostname, callback)
    @user = user
    activate_info = {"user_id" => user.id, "email_to_be_changed" => user.email_to_be_changed, "time" => Time.now.to_i}
    @activate_link = "#{protocol_hostname}#{callback}?key=" + CGI::escape(Encryption.encrypt_activate_key(activate_info.to_json))
    result = MongoidShortener.generate(@activate_link)
    @activate_link = "#{protocol_hostname}/#{result}" if result.present?
    data = {}
    data[:domain] = Rails.application.config.user_email_domain
    data[:from] = @@user_email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/change_email.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/change_email.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template.result(binding), :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:subject] = "更换账户邮箱"
    data[:subject] += " --- to #{user.email_to_be_changed}" if Rails.env != "production" 
    data[:to] = Rails.env == "production" ? user.email_to_be_changed : @@test_email
    self.send_message(data)
  end

  def self.find_password_email(user, protocol_hostname, callback)
    @user = user
    password_info = {"email" => user.email, "time" => Time.now.to_i}
    @password_link = "#{protocol_hostname}#{callback}?key=" + CGI::escape(Encryption.encrypt_activate_key(password_info.to_json))
    result = MongoidShortener.generate(@password_link)
    @password_link = "#{protocol_hostname}/#{result}" if result.present?
    data = {}
    data[:domain] = Rails.application.config.user_email_domain
    data[:from] = @@user_email_from

    html_template_file_name = "#{Rails.root}/app/views/user_mailer/find_password_email.html.erb"
    text_template_file_name = "#{Rails.root}/app/views/user_mailer/find_password_email.text.erb"
    html_template = ERB.new(File.new(html_template_file_name).read, nil, "%")
    text_template = ERB.new(File.new(text_template_file_name).read, nil, "%")
    premailer = Premailer.new(html_template.result(binding), :warn_level => Premailer::Warnings::SAFE)
    data[:html] = premailer.to_inline_css
    data[:text] = text_template.result(binding)

    data[:subject] = "找回密码"
    data[:subject] += " --- to #{user.email}" if Rails.env != "production" 
    data[:to] = Rails.env == "production" ? user.email : @@test_email
    self.send_message(data) 
  end

  def self.send_emagzine(subject, send_from, domain, content, attachment, emails)
    group_size = 900
    @group_emails = []
    @group_recipient_variables = []
    @emails = emails

    while @emails.length >= group_size
      temp_emails = @emails[0..group_size-1]
      @group_emails << temp_emails
      @emails = @emails[group_size..-1]
      temp_recipient_variables = {}
      temp_emails.each do |e|
        temp_recipient_variables[e] = {"email" => e}
      end
      @group_recipient_variables << temp_recipient_variables
    end
    @group_emails << @emails
    temp_recipient_variables = {}
    @emails.each do |e|
      temp_recipient_variables[e] = {"email" => e}
    end
    @group_recipient_variables << temp_recipient_variables

    @group_emails.each_with_index do |emails, i|
      data = {}
      data[:domain] = domain
      data[:from] = send_from
      data[:html] = content
      data[:text] = ""
      data[:attachment] = File.new(attachment) if attachment.present?
      data[:subject] = subject
      data[:subject] += " --- to #{@group_emails.flatten.length} emails" if Rails.env != "production" 
      data[:to] = Rails.env == "production" ? emails.join(', ') : @@test_email
      data[:'recipient-variables'] = @group_recipient_variables[i].to_json
      self.send_message(data)
    end
  end

  def self.send_message(data)
    # domain = data.delete(:domain)
    domain = data[:domain]
    begin
      retval = RestClient.post("https://api:#{Rails.application.config.mailgun_api_key}"\
        "@api.mailgun.net/v2/#{domain}/messages", data)
      retval = JSON.parse(retval)
      return retval["id"]
    rescue
      return -1
    end
  end
end
