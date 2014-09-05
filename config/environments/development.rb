MathLib::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # host name
  config.server_host = "http://www.b-fox.cn"

  # word processing host name
  config.word_host = "http://117.121.25.169"

  # image convertion url
  config.convert_image_url = "http://117.121.25.169"

  # converted image download url
  config.image_download_url = "http://117.121.25.169/download"

  # directory to save image files
  config.image_dir = "public/uploads/documents/images/"

  config.mailgun_api_key = "key-6o1gu03r0rslxbtbhczzt3912lrgdvk4"
end
