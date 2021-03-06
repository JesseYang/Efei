require 'rqrcode_png'
class QrcodesController < ApplicationController
  def index
    qr = RQRCode::QRCode.new("#{Rails.application.config.server_host}/~#{params[:link]}", :size => 4, :level => :h )
    png = qr.to_img
    temp_img_name = "public/qr_code/#{params[:link]}.png"
    png.resize(80, 80).save(temp_img_name)
    # render :text => "/qr_code/#{params[:link]}.png" and return
    send_file "public/qr_code/#{params[:link]}.png", type: 'image/png'
  end

  def student_android_app_qr_code
    size = params[:size].present? ? params[:size].to_i : 100
    qr = RQRCode::QRCode.new("#{Rails.application.config.student_android_app_url}", :size => 5, :level => :h )
    png = qr.to_img
    temp_img_name = "public/qr_code/student_android_app_url-#{size}.png"
    png.resize(size, size).save(temp_img_name)
    send_file temp_img_name, type: 'image/png'
  end

  def student_ios_app_qr_code
    size = params[:size].present? ? params[:size].to_i : 100
    qr = RQRCode::QRCode.new("#{Rails.application.config.student_ios_app_url}", :size => 5, :level => :h )
    png = qr.to_img
    temp_img_name = "public/qr_code/student_ios_app_url-#{size}.png"
    png.resize(size, size).save(temp_img_name)
    send_file temp_img_name, type: 'image/png'
  end
end
