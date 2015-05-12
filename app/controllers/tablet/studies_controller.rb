# encoding: utf-8
class Tablet::StudiesController < Tablet::ApplicationController

  def put
    student = User.find_by_auth_key(params[:id])
    student.update_studies(params[:studies])
    render_with_auth_key and return
  end
end
