# encoding: utf-8
class Homework::KlassesController < Homework::ApplicationController
  skip_before_filter :homework_init, only: :redirect

  def redirect
    redirect_to Platform.generate_authorize_link(Rails.application.config.server_host + "/homework/klasses") and return
  end

  def index
  end

  def list
  	@school = @current_user.school
  	@klasses = @school.klasses
  end
end
