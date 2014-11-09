class Array
  def mean
    return 0 if self.length == 0
    return self.sum.to_f / self.length
  end

  def before(e1, e2)
    return false if !self.include?(e1) || !self.include?(e2)
    return self.find_index(e1) < self.find_index(e2)
  end

  def render_question_for_edit
    table_index = -1
    for_edit_ary = self.map do |ele|
      if ele.class == String
        ele.render_question_for_edit
      elsif ele.class == Hash && ele["type"] == "table"
        table_index += 1
        "table#{table_index}"
      end
    end
    for_edit_ary.join("\r")
  end
end
