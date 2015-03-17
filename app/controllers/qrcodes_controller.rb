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
end
