# encoding: utf-8
module Concerns::Trashable
  extend ActiveSupport::Concern
 
  included do
    field :deleted_at, type: Integer
    field :in_trash, type: Boolean, default: false
    default_scope where(deleted_at: nil).where(:in_trash.ne => true)
  end
 
  module ClassMethods
    def trashed
      self.unscoped.where(:deleted_at.ne => nil)
    end
  end
 
  def trash
    update_attribute :deleted_at, Time.now.to_i
    if self.is_a? Folder
      self.set_children_in_trash
    end
  end

  def set_children_in_trash
    self.update_attribute :in_trash, true
    self.homeworks.each do |e|
      next if e.deleted_at.present?
      e.update_attribute :in_trash, true
    end
    self.children.each do |e|
      next if e.deleted_at.present?
      e.set_children_in_trash
    end
  end

  def set_children_out_trash
    self.update_attribute :in_trash, false
    self.homeworks.each do |e|
      next if e.deleted_at.present?
      e.update_attribute :in_trash, false
    end
    self.children.each do |e|
      next if e.deleted_at.present?
      e.set_children_out_trash
    end
  end
 
  def recover
    update_attribute :deleted_at, nil
    if self.is_a? Folder
      self.set_children_out_trash
    end
  end
end