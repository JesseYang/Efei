class Teacher::ApplicationController < ApplicationController
  layout 'layouts/teacher'

  before_filter :require_teacher
end
