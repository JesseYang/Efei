# encoding: utf-8
module Concerns::Trashable
  extend ActiveSupport::Concern
 
  included do
    field :deleted_at, type: Integer
    field :in_trash, type: Boolean, default: false
    default_scope -> { where(deleted_at: nil).where(:in_trash.ne => true) }
  end
 
  module ClassMethods
    def trashed
      self.where(:deleted_at.ne => nil)
    end
  end
 
  def trash
    update_attribute :deleted_at, Time.now.to_i
    if self.is_a? Folder
      self.set_children_in_trash
    end
    self.set_shares_in_trash
  end

  def set_shares_in_trash
    self.shares.unscoped.each do |e|
      next if e.deleted_at.present?
      e.update_attribute :in_trash, true
    end
  end

  def set_shares_out_trash
    self.shares.unscoped.each do |e|
      next if e.deleted_at.present?
      e.update_attribute :in_trash, false
    end
  end

  def set_children_in_trash
    self.children.unscoped.each do |e|
      next if e.deleted_at.present?
      e.update_attribute :in_trash, true
      e.set_shares_in_trash
    end
    self.children.unscoped.each do |e|
      next if e.deleted_at.present?
      e.set_children_in_trash if e.is_a? Folder
    end
  end

  def set_children_out_trash
    self.children.unscoped.each do |e|
      next if e.deleted_at.present?
      e.update_attribute :in_trash, false
      e.set_shares_out_trash
    end
    self.children.unscoped.each do |e|
      next if e.deleted_at.present?
      e.set_children_out_trash if e.is_a? Folder
    end
  end
 
  def recover
    update_attribute :deleted_at, nil
    if self.is_a? Folder
      self.set_children_out_trash
    end
    self.set_shares_out_trash
  end
end