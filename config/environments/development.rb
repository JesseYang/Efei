Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  # config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # host name
  config.server_host = "http://dev.efei.org"

  # word processing host name
  config.word_host = "http://dev.image.efei.org"

  # tex2gif service host name
  config.tex_host = "http://tex.efei.org/cgi-bin/mathtex.cgi?"

  # slide parsing host name
  config.slides_host = "http://dev.image.efei.org"

  # image convertion url
  config.convert_image_url = "http://dev.image.efei.org"

  # converted image download url
  config.image_download_url = "http://dev.image.efei.org/download"

  # directory to save image files
  config.image_dir = "public/uploads/documents/images/"

  config.mailgun_api_key = "key-6o1gu03r0rslxbtbhczzt3912lrgdvk4"

  config.email_expire_time = 86400

  config.expire_time = 3600
end
