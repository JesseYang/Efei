# encoding: utf-8
# require 'RMagick'

class String
  CF = 1.3

  def is_mobile?
    !self.match(/1\d{10}/).nil?
  end

  def is_separate?
    self.length > 1 && self.match(/-+/).present? && self.match(/-+/)[0] == self
  end

  def render_question
    result = ""
    self.split('$$').each do |f|
      if f.start_with?("equ_") || f.start_with?("math_")
        image_type, filename, width, height = f.split(/\*|_/)
        result += "<img src='#{Rails.application.config.word_host}/public/download/#{filename}.png' width='#{width.to_f * CF}' height='#{height.to_f * CF}'></img>"
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
