#encoding: utf-8
module ApplicationHelper
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def lesson_helper(i)
    ary = %w{一 二 三 四 五 六 七 八 九 十 十一 十二 十三 十四 十五 十六 十七 十八 十九 二十 二十一 二十二 二十三 二十四 二十五 二十六 二 十七 二十八 二十九 三十 三十一 三十二 三十三 三十四 三十五 三十六 三十七 三十八 三十九 四十}
    "第" + ary[i] + "讲："
  end

  def d2c(d)
    case d
    when 0
      return "A"
    when 1
      return "B"
    when 2
      return "C"
    when 3
      return "D"
    else
      return "E"
    end
  end

  def difficulty_show(d)
    case d
    when 1
      "中等"
    when 2
      "困难"
    else
      "简单"
    end
  end

  def question_type_show(type)
    case type
    when "choice"
      "选择题"
    when "blank"
      "填空题"
    else
      "解答题"
    end
  end

  def zonghe_year
    { "不限" => 0, "2014" => 2014, "2013" => 2013, "2012" => 2012, "2011" => 2011, "2010" => 2010 }
  end

  def zonghe_province
    {
      "不限" => 0, "江西"=>"江西", "陕西"=>"陕西", "重庆"=>"重庆", "安徽"=>"安徽", "北京"=>"北京", "山东"=>"山东", "四川"=>"四川", "江苏"=>"江苏", "广东"=>"广东", "辽宁"=>"辽宁", "福建"=>"福建", "浙江"=>"浙江", "上海"=>"上海", "天津"=>"天津", "湖南"=>"湖南", "湖北"=>"湖北"
    }
  end

  def zonghe_type
    {
      "不限" => 0, "高考真题" => "高考真题", "高考模拟" => "高考模拟"
    }
  end

  def tiku_type
    { "同步练习" => 0, "专项练习" => 1, "综合套题" => 2}
  end

  def note_type_search
    { "全部类型" => 0, "不懂" => 1, "不会" => 2, "不对" => 3, "典型题" => 4 }
  end

  def note_type
    { "请选择" => 0, "不懂" => 1, "不会" => 2, "不对" => 3, "典型题" => 4 }
  end

  def paginator_mini(paginator)
    render :partial => "application/paginator_mini",  :locals => {
      :paginator => paginator
    }
  end

  def table_sort_header(text, name)
    render :partial => "application/table_sort_header",  :locals => {
      :text => text,
      :name => name
    }
  end

  def sort_caret(sort, dir)
    return "" if !sort
    return " ▲" if dir == "true"
    return " ▼"
  end

  def truncate_u(text, length = 30, truncate_string = "...")  
    l=0  
    char_array=text.unpack("U*")  
    char_array.each_with_index do |c,i|  
      l = l+ (c<127 ? 0.5 : 1)  
      if l>=length  
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")  
      end  
    end  
    return text  
  end

  def subject
    {
      "全部科目" => 0,
      "语文" => 1,
      "数学" => 2,
      "英语" => 4,
      "物理" => 8,
      "化学" => 16,
      "生物" => 32,
      "历史" => 64,
      "地理" => 128,
      "政治" => 256,
      "其他" => 512
    }
  end

  def time_period
    {
      "全部时间" => 0,
      "最近一周" => 7.days.to_i,
      "最近一个月" => 1.months.to_i,
      "最近三个月" => 3.months.to_i,
      "最近半年" => 6.months.to_i,
    }
  end

  def ary2hash(ary)
    h = { }
    ary.each_with_index do |e, i|
      h[e.to_s] = i
    end
    h
  end
end
