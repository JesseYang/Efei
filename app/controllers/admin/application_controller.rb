class Admin::ApplicationController < ApplicationController

  before_filter :require_admin

  layout 'layouts/admin'
end
