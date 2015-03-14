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

  def time_period
    {
      "全部时间" => Time.now.to_i,
      "最近一天" => 1.days.to_i, 
      "最近三天" => 3.days.to_i,
      "最近一周" => 7.days.to_i,
      "最近两周" => 2.weeks.to_i,
      "最近一个月" => 1.months.to_i
    }
  end
end
