class Integer
  def to_capital
    return ("A".."Z").to_a[self]
  end

  def to_abcd
    case self
    when 0
      "D"
    when 1
      "D+"
    when 2
      "C-"
    when 3
      "C"
    when 4
      "C+"
    when 5
      "B-"
    when 6
      "B"
    when 7
      "B+"
    when 8
      "A-"
    when 9
      "A"
    when 10
      "A+"
    else
      ""
    end
  end

  def to_time
    time = self
    str = ""
    if time > 3600
      str += (time / 3600).to_s + "小时"
      time = time % 3600
    end
    if time > 60
      str += (time / 60).to_s + "分"
      time = time % 60
    end
    if time >= 0
      str += time.to_s + "秒"
    end
  end
end
