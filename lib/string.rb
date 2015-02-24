# encoding: utf-8
# require 'RMagick'

class String
  CF = 1

  def is_mobile?
    !self.match(/1\d{10}/).nil?
  end

  def is_separate?
    self.length > 1 && self.match(/-+/).present? && self.match(/-+/)[0] == self
  end

  def item_length
    length = 0
    self.split('$$').each do |f|
      if f.start_with?("equ_") || f.start_with?("math_") || f.start_with?("fig_")
        image_type, filename, file_type, width, height = f.split(/\*|_/)
        length += width.to_i / 8
      else
        length += f.length
      end
    end
    length
  end

  def render_material
    result = ""
    self.split('$$').each do |f|
      if f.start_with?("equ_")
        result += "<img src=\"#{Rails.application.config.tex_host}#{f[4..-1]}\"></img>"
      elsif f.start_with?("img_")
        tmp, image_type, filename = f.split(/\*|_/)
        result += "<img src=\"/material_images/#{filename}.#{image_type}\"></img>"
      elsif f.start_with?("und_")
        result += "<u>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</u>"
      elsif f.start_with?("sub_")
        result += "<sub>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</sub>"
      elsif f.start_with?("sup_")
        result += "<sup>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</sup>"
      else
        result += "<span>#{f.gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</span>"
      end
    end
    result
  end

  def render_question(image_path = Rails.application.config.word_host + "/public/download")
    image_path ||= Rails.application.config.word_host + "/public/download"
    result = ""
    self.split('$$').each do |f|
      if f.start_with?("equ_") || f.start_with?("math_") || f.start_with?("fig_")
        image_type, filename, filetype, width, height = f.split(/\*|_/)
        result += "<img src='#{image_path}/#{filename}.#{filetype}' width='#{width.to_f * CF}' height='#{height.to_f * CF}'></img>"
      elsif f.start_with?("sub_")
        result += "<sub>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</sub>"
      elsif f.start_with?("sup_")
        result += "<sup>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</sup>"
      elsif f.start_with?("und_")
        result += "<u>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</u>"
      elsif f.start_with?("ita_")
        result += "<i>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</i>"
      else
        result += "<span>#{f.gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</span>"
      end
    end
    result
  end

  def render_resource
    result = ""
    self.split('$$').each do |f|
      if f.start_with?("img_")
        tmp, image_type, filename = f.split(/\*|_/)
        result += "<img src='/external_images/#{filename}.#{image_type}'></img>"
      elsif f.start_with?("sub_")
        result += "<sub>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</sub>"
      elsif f.start_with?("sup_")
        result += "<sup>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</sup>"
      elsif f.start_with?("und_")
        result += "<u>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</u>"
      elsif f.start_with?("ita_")
        result += "<i>#{f[4..-1].gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</i>"
      else
        result += "<span>#{f.gsub("<", "&lt;").gsub(">", "&gt;").gsub(" ", "&nbsp")}</span>"
      end
    end
    result
  end

  def render_figure
    image_type, filename, width, height = self[2..-3].split(/\*|_/)
    "<img src='#{Rails.application.config.word_host}/public/download/#{filename}.png' width='#{width.to_f * CF}', height='#{height.to_f * CF}'></img>"
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
