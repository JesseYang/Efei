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

  index({ external_id: 1 }, { unique: true, name: "external_id_index" })


  @@chn = false
  @@img_save_folder = "public/material_images/"
  @@domain = "http://kuailexue.com"
  @name = ""

  def self.parse(dir = "public/materials/*")
    rom = ["", "I. ", "II. ", "III. ", "IV. ", "V. ", "VI. "]
    Dir[dir].each do |path|
      name = path.split("/")[-1]
      @name = name
      next if name.start_with?("done")
      # category = name.split('_')[0]
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
          choice_without_items = false
          external_id = q_ele.attr("data-id")
          next if external_id == "null" || external_id.nil?
          m = Material.where(external_id: external_id).first
          next if m.present?
          content = []
          q_ele.css("stem").each_with_index do |s, i|
            content += self.parse_content(s, rom[i])
          end
          if type == "选择题"
            if q_ele.css("opts").first.present?
              items = self.parse_options(q_ele.css("opts").first)
            else
              choice_without_items = true
            end
          end
          tags = []
          q_ele.css(".q_tags").each do |t|
            tags += t.css("li").map { |e| { id: e.attr("tid"), text: e.text } }
          end
          category = tags[0]
          tags.uniq!
          difficulty = q_ele.css(".diffculty").first.css("li").length
          answer_nodes = q_ele.css(".answer")
          if answer_nodes.length == 1
            answer_ele = answer_nodes.css(".dd").first
            answer = self.parse_content(answer_ele)
          else
            answer_ele = answer_nodes.map { |e| e.css(".dd").first } 
            answer = []
            answer_ele.each_with_index do |e, i|
              answer += self.parse_content(e, rom[i+1])
            end
          end
          answer_content_part = q_ele.css(".exp").first
          if answer_content_part.present?
            answer_content_ele = answer_content_part.css(".dd").first
            answer_content = self.parse_content(answer_content_ele)
          end
          Material.create(external_id: external_id, subject: 2, type: type, difficulty: difficulty, content: content, items: items, tags: tags, answer: answer, answer_content: answer_content, category: category, dangerous: @@chn, choice_without_items: choice_without_items)
          @@chn = false
        end
      end
      new_name = "done_#{name}"
      new_path = ( path.split("/")[0..-2] + [new_name] ).join("/")
      File.rename(path, new_path)
    end
  end

  def self.parse_options(options)
    items = options.xpath("opt").map do |opt|
      self.parse_content(opt)
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
        if r.blank?
          equ = Material.replace_equ(e.children[0].text)
          @@chn = true if equ.scan(/[\u4e00-\u9fa5]/).present?
          cur_text += "$$equ_#{equ}$$"
        else
          content << cur_text if cur_text.present?
          cur_text = ""
          equs = r[0][0].split("\\\\")
          equs.each do |e|
            equ = Material.replace_equ(e)
            @@chn = true if equ.scan(/[\u4e00-\u9fa5]/).present?
            content << "$$equ_#{equ}$$"
          end
        end
      elsif e.children.length > 0
        cur_text += self.parse_content(e).join
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

  def self.replace_equ(s)
    s.gsub("①", "\\textcircled{1}")
    .gsub("②", "\\textcircled{2}")
    .gsub("③", "\\textcircled{3}")
    .gsub("④", "\\textcircled{4}")
    .gsub("⑤", "\\textcircled{5}")
    .gsub("⑥", "\\textcircled{6}")
    .gsub("⑦", "\\textcircled{7}")
    .gsub("⑧", "\\textcircled{8}")
    .gsub("⑨", "\\textcircled{9}")
    .gsub("⑩", "\\textcircled{10}")
    .gsub("′", "'")
    .gsub("（", "(")
    .gsub("）", ")")
    .gsub("＋", "+")
    .gsub("－", "-")
    .gsub("＝", "=")
  end

  def self.select_circle
    ms = []
    Material.all.select do |m|
      included = false
      m.content.each do |line|
        line.split("$$").each do |frag|
          next if !frag.start_with?("equ_")
          if frag.include?("①") || frag.include?("②") || frag.include?("③") || frag.include?("④") || frag.include?("⑤") || frag.include?("⑥") || frag.include?("⑦") || frag.include?("⑧") || frag.include?("⑨") || frag.include?("⑩")
            included = true
            break
          end
        end
        break if included == true
      end
      if included == true
        ms << m
        next
      end

      if m.items.present?
        m.items.each do |item|
          item.each do |line|
            line.split("$$").each do |frag|
              next if !frag.start_with?("equ_")
              if frag.include?("①") || frag.include?("②") || frag.include?("③") || frag.include?("④") || frag.include?("⑤") || frag.include?("⑥") || frag.include?("⑦") || frag.include?("⑧") || frag.include?("⑨") || frag.include?("⑩")
                included = true
                break
              end
            end
            break if included == true
          end
          break if included == true
        end
        if included == true
          ms << m
          next
        end
      end

      (m.answer || []).each do |line|
        line.split("$$").each do |frag|
          next if !frag.start_with?("equ_")
          if frag.include?("①") || frag.include?("②") || frag.include?("③") || frag.include?("④") || frag.include?("⑤") || frag.include?("⑥") || frag.include?("⑦") || frag.include?("⑧") || frag.include?("⑨") || frag.include?("⑩")
            included = true
            break
          end
        end
        break if included == true
      end
      if included == true
        ms << m
        next
      end

      (m.answer_content || []).each do |line|
        line.split("$$").each do |frag|
          next if !frag.start_with?("equ_")
          if frag.include?("①") || frag.include?("②") || frag.include?("③") || frag.include?("④") || frag.include?("⑤") || frag.include?("⑥") || frag.include?("⑦") || frag.include?("⑧") || frag.include?("⑨") || frag.include?("⑩")
            included = true
            break
          end
        end
        break if included == true
      end
      if included == true
        ms << m
        next
      end
    end
    ms
  end

  def replace_circle
    new_content = self.content.map do |line|
      frags = line.split("$$").map do |frag|
        if frag.start_with?("equ_")
          Material.replace_string(frag)
        else
          frag
        end
      end
      if line.end_with?("$$")
        frags.join("$$") + "$$"
      else
        frags.join("$$")
      end
    end

    if self.items.present?
      new_items = self.items.map do |item|
        new_item = item.map do |line|
          frags = line.split("$$").map do |frag|
            if frag.start_with?("equ_")
              Material.replace_string(frag)
            else
              frag
            end
          end
          if line.end_with?("$$")
            frags.join("$$") + "$$"
          else
            frags.join("$$")
          end
        end
        new_item
      end
    end

    if self.answer.present?
      new_answer = self.answer.map do |line|
        frags = line.split("$$").map do |frag|
          if frag.start_with?("equ_")
            Material.replace_string(frag)
          else
            frag
          end
        end
        if line.end_with?("$$")
          frags.join("$$") + "$$"
        else
          frags.join("$$")
        end
      end
    end

    if self.answer_content.present?
      new_answer_content = self.answer_content.map do |line|
        frags = line.split("$$").map do |frag|
          if frag.start_with?("equ_")
            Material.replace_string(frag)
          else
            frag
          end
        end
        if line.end_with?("$$")
          frags.join("$$") + "$$"
        else
          frags.join("$$")
        end
      end
    end

    self.content = new_content
    self.items = new_items
    self.answer = new_answer
    self.answer_content = new_answer_content
    self.save
  end

  def self.replace_string(s)
    s.gsub("①", "\\textcircled{1}")
    .gsub("②", "\\textcircled{2}")
    .gsub("③", "\\textcircled{3}")
    .gsub("④", "\\textcircled{4}")
    .gsub("⑤", "\\textcircled{5}")
    .gsub("⑥", "\\textcircled{6}")
    .gsub("⑦", "\\textcircled{7}")
    .gsub("⑧", "\\textcircled{8}")
    .gsub("⑨", "\\textcircled{9}")
    .gsub("⑩", "\\textcircled{10}")
  end

  def to_s
    self.content.join + (self.items || []).map { |item| item.join } .join + (self.answer || []).join + (self.answer_content || []).join
  end

  def equ_to_s
    s = self.to_s
    s.split("$$").select do |e|
      e.start_with?("equ_")
    end .join("$$")
  end
end
