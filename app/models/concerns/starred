# encoding: utf-8
module Concerns::Starred
  extend ActiveSupport::Concern
 
  included do
    field :starred, type: Boolean, default: false
  end
 
  module ClassMethods
    def starred
      self.where(starred: true)
    end
  end
 
  def star
    update_attribute :starred, true
  end
 
  def unstar
    update_attribute :starred, false
  end
end