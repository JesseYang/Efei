class SchoolAdmin::ApplicationController < ApplicationController
  layout 'layouts/school_admin'

  before_filter :require_school_admin
end
