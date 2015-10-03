class Integer
  def to_capital
    return ("A".."Z").to_a[self]
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
