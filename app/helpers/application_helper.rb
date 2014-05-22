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
      "全部" => 0,
      "最近一天" => 1, 
      "最近三天" => 2,
      "最近一周" => 4,
      "最近两周" => 8,
      "最近一个月" => 16
    }
  end
end
