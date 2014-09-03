# encoding: utf-8
require 'RMagick'

class String
  CF = 1.3
  def is_separate?
    self.length > 1 && self.match(/-+/).present? && self.match(/-+/)[0] == self
  end

  def convert_img_type
    images = []
    # img_dir = "public/uploads/documents/images"
    self.scan(/\$(.*?)\$/).each do |image|
      image_info = image[0]
      type, filename, width, height = *image_info.split('*')
      name = filename.split('.')[0]
      suffix = filename.split('.')[1]
      if !%w{jpeg png jpg bmp}.include?(suffix)
        # convert the image to jpg
        # i = Magick::Image.read("#{img_dir}/#{filename}").first
        # i.trim.write("#{img_dir}/#{name}.png") { self.quality = 1 }
        self.gsub!(filename, "#{name}.png")
        # File.delete("#{img_dir}/#{filename}")
        # images << "#{name}.png"
      # else
        # images << filename
      end
      images << filename
    end
    images
  end

  def render_question
    result = ""
    self.split('$').each do |f|
      if f.match(/[a-z 0-9]{8}-[a-z 0-9]{4}-[a-z 0-9]{4}-[a-z 0-9]{4}-[a-z 0-9]{12}/)
        # equation
        image_type, filename, width, height = f.split('*')
        result += "<img src='/uploads/documents/images/#{filename}' width='#{width.to_f * CF}' height='#{height.to_f * CF}'></img>"
      else
        # text
        result += "<span>#{f}</span>"
      end
    end
    result
  end

  def render_figure
    image_type, filename, width, height = self[1..-2].split('*')
    "<img src='/uploads/documents/images/#{filename}' width='#{width.to_f * CF}', height='#{height.to_f * CF}'></img>"
  end

  def render_question_for_edit
    img_dir = "public/uploads/documents/images"
    result = ""
    self.split('$').each do |f|
      if f.match(/[a-z 0-9]{8}-[a-z 0-9]{4}-[a-z 0-9]{4}-[a-z 0-9]{4}-[a-z 0-9]{12}/)
        # equation
        result += "$#{f.split('-')[0]}$"
      else
        # text
        result += f
      end
    end
    result
  end
end
