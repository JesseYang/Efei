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
    Dir[dir].each do |path|
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
          choice_without_items = false
          external_id = q_ele.attr("data-id")
          next if external_id == "null" || external_id.nil?
          m = Material.where(external_id: external_id).first
          next if m.check != true
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
          Material.create(external_id: external_id, subject: 2, type: type, difficulty: difficulty, content: content, items: items, tags: tags, answer: answer, answer_content: answer_content, category: category, dangerous: @@chn, choice_without_items: choice_without_items, check: true)
          q = Question.where(external_id: external_id).first
          q.destroy
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
          # equ = e.children[0].text.gsub('∴', '\therefore').gsub("或", "\\ or\\ ").gsub("且", "\\ and\\ ").gsub("即", "\\therefore")
          equ = e.children[0].text
          @@chn = true if equ.scan(/[\u4e00-\u9fa5]/).present?
          cur_text += "$$equ_#{equ}$$"
        else
          content << cur_text if cur_text.present?
          cur_text = ""
          equs = r[0][0].split("\\\\")
          equs.each do |e|
            # equ = e.gsub('∴', '\therefore').gsub("或", "\\ or\\ ").gsub("且", "\\ and\\ ").gsub("即", "\\therefore")
            equ = e
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

  def self.check
    materials = Material.all.to_a
    materials.each_with_index do |m, i|
      if i % 100 == 0
        puts i
      end
      check = false
      str = m.content.join + (m.answer || []).join + (m.answer_content || []).join + ((m.items || []).map { |e| e.join }).join
      if str.include?("'")
        m.update_attribute :check, true
      end
    end
  end
end
