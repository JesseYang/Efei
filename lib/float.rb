class Float
  def to_time
    return "#{self.round / 60}分#{self.round%60}秒"
  end
end
