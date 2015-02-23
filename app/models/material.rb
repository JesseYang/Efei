# encoding: utf-8
class Material
  include Mongoid::Document
  include Mongoid::Timestamps

  field :external_id, type: String
  field :subject, type: Integer
  field :type, type: String
  field :difficulty, type: Integer
  field :content, type: Array, default: []
  field :content_old, type: Array, default: []
  field :content_preview, type: Array, default:[]
  field :items, type: Array, default: []
  field :items_old, type: Array, default: []
  field :items_preview, type: Array, default: []
  field :answer, type: Array, default: []
  field :answer_old, type: Array, default: []
  field :answer_preview, type: Array, default: []
  field :answer_content, type: Array, default: []
  field :answer_content_old, type: Array, default: []
  field :answer_content_preview, type: Array, default: []
  field :tags, type: Array, default: []
  field :category, type: String
  field :dangerous, type: Boolean
  field :choice_without_items, type: Boolean, default: false
  field :paper, type: Boolean, default: false
  field :imported, type: Boolean, default: false

  field :check, type: Boolean, default: false

  index({ external_id: 1 }, { unique: true, name: "external_id_index" })


  @@chn = false
  @@img_save_folder = "public/material_images/"
  @@domain = "http://kuailexue.com"
  @name = ""

  def self.parse(dir = "public/materials/*")
    rom = ["", "I. ", "II. ", "III. ", "IV. ", "V. ", "VI. "]
    ii = 0
    Dir[dir].each do |path|
      ii += 1
      puts ii
      name = path.split("/")[-1]
      @name = name
      # next if name.start_with?("done")
      category = name.split('_')[0]
      f = File.open(path)
      c = f.read
      f.close
      p = Nokogiri::HTML(c)
      parts = p.css("#parts")[0]
      parts.children.each do |e|
        part_header = e.css(".part_header").first
        type = part_header.css(".item_name")[0].text
        part_body = e.css(".part_body").first
        q_ele_ary = part_body.xpath("div")
        q_ele_ary.each do |q_ele|
          ret = false
          choice_without_items = false
          external_id = q_ele.attr("data-id")
          next if external_id == "null" || external_id.nil?
          # next if Material.where(external_id: external_id).first.present?
          content = []
          q_ele.css("stem").each_with_index do |s, i|
            ret = self.parse_content(s, rom[i])
            if ret == true
              m = Material.where(external_id: external_id).first
              m.update_attribute(:check, true) if m.present?
              break
            end
            content += ret
          end
          next if ret == true
          if type == "选择题"
            if q_ele.css("opts").first.present?
              ret = self.parse_options(q_ele.css("opts").first)
              if ret == true
                m = Material.where(external_id: external_id).first
                m.update_attribute(:check, true) if m.present?
                next
              end
              items = ret
            else
              choice_without_items = true
            end
          end
          tags = []
          q_ele.css(".q_tags").each do |t|
            tags += t.css("li").map { |e| { id: e.attr("tid"), text: e.text } }
          end
          tags.uniq!
          difficulty = q_ele.css(".diffculty").first.css("li").length
          answer_nodes = q_ele.css(".answer")
          if answer_nodes.length == 1
            answer_ele = answer_nodes.css(".dd").first
            ret = self.parse_content(answer_ele)
            if ret == true
              m = Material.where(external_id: external_id).first
              m.update_attribute(:check, true) if m.present?
              next
            end
            answer = ret
          else
            answer_ele = answer_nodes.map { |e| e.css(".dd").first } 
            answer = []
            answer_ele.each_with_index do |e, i|
              ret += self.parse_content(e, rom[i+1])
              if ret == true
                m = Material.where(external_id: external_id).first
                m.update_attribute(:check, true) if m.present?
                break
              end
              answer += ret
            end
            next if ret == true
          end
          answer_content_part = q_ele.css(".exp").first
          if answer_content_part.present?
            answer_content_ele = answer_content_part.css(".dd").first
            ret = self.parse_content(answer_content_ele)
            if ret == true
              m = Material.where(external_id: external_id).first
              m.update_attribute(:check, true) if m.present?
              next
            end
            answer_content = ret
          end
          # Material.create(external_id: external_id, subject: 2, type: type, difficulty: difficulty, content: content, items: items, tags: tags, answer: answer, answer_content: answer_content, category: category, dangerous: @@chn, choice_without_items: choice_without_items)
          @@chn = false
        end
      end
      # new_name = "done_#{name}"
      # new_path = ( path.split("/")[0..-2] + [new_name] ).join("/")
      # File.rename(path, new_path)
    end
  end

  def self.parse_options(options)
    items = options.xpath("opt").map do |opt|
      ret = self.parse_content(opt)
      return true if ret == true
    end
  end

  def self.parse_content(ele, pre = "")
    content = []
    cur_text = pre || ""
    new_line = false
    ele.children.each do |e|
      if e.name == "br"
        content << cur_text
        cur_text = ""
      elsif e.name == "img"
        img_id = SecureRandom.uuid
        img_type = e.attr('src').split('.')[-1]
        File.open("#{@@img_save_folder}#{img_id}.#{img_type}", 'wb') do |fo|
          fo.write open(@@domain + e.attr('src')).read 
        end
        cur_text += "$$img_#{img_type}*#{img_id}$$"
      elsif e.name == "div" && e.attr("class").to_s.include?("MathJax_Display")
        content << cur_text
        cur_text = ""
        new_line = true
        next
      elsif e.name == "text"
        cur_text += e.text
      elsif e.name == "nn"
        cur_text += "$$und_#{e.text}$$"
      elsif e.name == "span" && e.attr("class").to_s.include?("MathJax_Preview")
        next
      elsif e.name == "span" && e.attr("class").to_s.include?("MathJax")
        next
      elsif e.name == "script" && e.children[0].present? && e.children[0].name == "#cdata-section"
        r = e.children[0].text.scan(/^\\begin\{split\}(.+)\\end\{split\}$/)
        if r.present?
          return true
        end
        # if r.blank?
        # equ = e.children[0].text.gsub('∴', '\therefore').gsub("或", "\\ or\\ ").gsub("且", "\\ and\\ ").gsub("即", "\\therefore")
        equ = e.children[0].text
        return true if equ.include?("∴") || equ.include?("或") || equ.include?("且") || equ.include?("即")
        @@chn = true if equ.scan(/[\u4e00-\u9fa5]/).present?
        cur_text += "$$equ_#{equ}$$"
=begin
        else
          content << cur_text if cur_text.present?
          cur_text = ""
          equs = r[0][0].split("\\\\")
          equs.each do |e|
            # equ = e.gsub('∴', '\therefore').gsub("或", "\\ or\\ ").gsub("且", "\\ and\\ ").gsub("即", "\\therefore")
            equ = e
            return true if equ.include?("∴") || equ.include?("或") || equ.include?("且") || equ.include?("即")
            @@chn = true if equ.scan(/[\u4e00-\u9fa5]/).present?
            content << "$$equ_#{equ}$$"
          end
        end
=end
      elsif e.children.length > 0
        ret = self.parse_content(e)
        return true if ret == true
        cur_text += ret.join
      else
        cur_text += e.text
      end
      if new_line
        content << cur_text if cur_text.present?
        cur_text = ""
        new_line = false
      end
    end
    content << cur_text
    content
  end
end
