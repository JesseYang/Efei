class String
  def is_separate?
    self.length > 1 && self.match(/-+/).present? && self.match(/-+/)[0] == self
  end
end
