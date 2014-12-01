require 'rqrcode_png'
class QrcodesController < ApplicationController
  def index
    qr = RQRCode::QRCode.new(params[:link], :size => 2, :level => :l )
    Rails.logger.info "AAAAAAAAAAAAAAAAAAAAA"
    Rails.logger.info "#{Rails.application.config.server_host}/~#{params[:link]}"
    Rails.logger.info "AAAAAAAAAAAAAAAAAAAAA"
    png = qr.to_img
    temp_img_name = "public/qr_code/#{params[:link]}.png"
    png.resize(50, 50).save(temp_img_name)
    # render :text => "/qr_code/#{params[:link]}.png" and return
    send_file "public/qr_code/#{params[:link]}.png", type: 'image/png'
  end
end
