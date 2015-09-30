require 'integer'

class Float
  def to_time
    self.round.to_time
  end
end
