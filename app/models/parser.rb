class Parser

  def self.safe_open_page(uri)
    page = nil
    while page.nil?
      begin
        page = Nokogiri::HTML(open(uri))
      rescue
        page = nil
        puts "fail to open #{uri} and sleep 10 seconds"
        sleep(10)
      end
    end
    return page
  end

  def self.parse_root
    page = self.safe_open_page("http://www.mofangge.com/qlist/shuxue")

    page.css("#ul_hidbk_470").xpath("li").each do |e|
      link = e.css('a')[0]
      structure_uri = link.attr("href")
      structure = Resource.where(uri: structure_uri).first
      if structure.present? && structure.status == "done"
        next
      end
      structure = Resource.create(uri: structure_uri, subject: 2, type: "structure", status: "doing") if structure.blank?

      self.parse_one_structure(structure)

      structure.update_attribute(:status, "done")
    end
  end

  def self.parse_one_structure(structure)
    s_page = self.safe_open_page(structure.uri)

    page_number = s_page.css(".seopage")[0].css("a").length
    page_index = (1..page_number).to_a.map { |e| e.to_s }
    page_index[0] = ""

    page_index.each do |e|
      p_uri = structure.uri + e
      puts p_uri
      cur_page = self.safe_open_page(p_uri)
      list = cur_page.css(".seoleftul")[0]
      list.xpath("li").each do |li|
        q_uri = li.css("a")[0].attr("href")
        self.parse_one_page(structure, q_uri)
      end
    end
  end

  def self.save_parse_one_page(structure, uri)
    success = false
    while !success
      begin
        self.parse_one_page(structure, uri)
        success = true
      rescue
        puts "fail to parse page: #{uri}"
      end
    end
  end


  def self.parse_one_page(structure, uri)
    puts uri

    # skip those already saved
    if Resource.where(uri: uri).first.present?
      puts "skip one"
      return
    end

    # sleep to slow down
    sleep(5)

    @@img_save_folder = "public/external_images/"
    page = self.safe_open_page(uri)
    # the info part
    info_ele = page.css("div.provider#q_indexkuai2211").css('div#q_indexkuai22111')
    info = info_ele.css('span').map { |e| e.text }

    # the question content part
    content = []
    q_div = page.css('div#q_indexkuai22')
    q_table = q_div.css('table')[0]
    q_tds = self.extract_tds(q_table)
    q_tds.each do |e|
      content += self.parse_ele(e)
    end

    # the question answer and analysis part
    a_div = page.css('div#q_indexkuai321')
    if info[0].include?("单选") || info[0].include?("填空")
      answer_table = a_div.xpath("table")[0]
      analysis_table = a_div.xpath("table")[1]
    else
      analysis_table = a_div.xpath("table")[0]
    end

    answer = self.parse_ele(answer_table) if answer_table.present?
    analysis = self.parse_ele(analysis_table)

    q = Resource.create(uri: uri, subject: 2, type: "question", info: info, content: content, answer: answer, answer_content: analysis)
    structure.questions << q

    puts "one more at: " + Time.now.to_s
  end

  def self.parse_ele(ele)
    content = []
    cur_text = ""
    ele.children.each do |e|
      case e.name
      when "text"
        cur_text += e.text
      when "img"
        img_id = SecureRandom.uuid
        img_type = e.attr('src').split('.')[-1]
        File.open("#{@@img_save_folder}#{img_id}.#{img_type}", 'wb') do |fo|
          fo.write open(e.attr('src')).read 
        end
        cur_text += "$$img_#{img_type}*#{img_id}$$"
      when "sup"
        cur_text += "$$sup_#{e.text}$$"
      when "sub"
        cur_text += "$$sub_#{e.text}$$"
      when "u"
        cur_text += "$$und_#{e.text}$$"
      when "br"
        content << cur_text
        cur_text = ""
      when "div"
        if cur_text.present?
          content << cur_text
          cur_text = ""
        end
        content += self.parse_ele(e)
      when "p"
        if cur_text.present?
          content << cur_text
          cur_text = ""
        end
        content += self.parse_ele(e)
      when "table"
        if cur_text.present?
          content << cur_text
          cur_text = ""
        end
        if e.attr("style").present? && e.attr("style").include?("BORDER-COLLAPSE")
          content += ["table_#{e.to_s}"]
        else
          tds = self.extract_tds(e)
          tds.each do |td|
            content += self.parse_ele(td)
          end
        end
      when "tbody"
        if cur_text.present?
          content << cur_text
          cur_text = ""
        end
        tds = e.xpath('tr').xpath('td')
        tds.each do |td|
          content += self.parse_ele(td)
        end
      when "tr"
        if cur_text.present?
          content << cur_text
          cur_text = ""
        end
        tds = e.xpath('td')
        tds.each do |td|
          content += self.parse_ele(td)
        end
      end
    end
    content << cur_text if cur_text.present?
    content
  end

  def self.extract_tds(table)
    tbody = table.xpath('tbody')
    if tbody.present?
      tbody.xpath('tr').xpath('td')
    else
      table.xpath('tr').xpath('td')
    end
  end
end
