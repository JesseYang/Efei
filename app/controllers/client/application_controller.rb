class Client::ApplicationController < ApplicationController
  layout 'layouts/client'

  before_filter :client_init

  def client_init
  end
end
