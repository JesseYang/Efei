# encoding: utf-8
module Concerns::Trashable
  extend ActiveSupport::Concern
 
  included do
    field :deleted_at, type: Integer
    default_scope where(deleted_at: nil)
  end
 
  module ClassMethods
    def trashed
      self.where(:deleted_at.ne => nil)
      self.unscoped.where(:deleted_at.ne => nil)
    end
  end
 
  def trash
    update_attribute :deleted_at, Time.now.to_i
  end
 
  def recover
    update_attribute :deleted_at, nil
  end
end