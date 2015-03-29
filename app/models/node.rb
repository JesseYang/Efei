# encoding: utf-8
class Node
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::Trashable
  include Concerns::Starred
  field :name, type: String
  belongs_to :user, class_name: "User", inverse_of: :nodes
  belongs_to :parent, class_name: "Folder", inverse_of: :children
  has_many :shares, class_name: "Share", inverse_of: :node

  def last_update_time
    self.updated_at.today? ? self.updated_at.strftime("%H点%M分") : self.updated_at.strftime("%Y年%m月%d日")
  end

  def self.list_trash
    self.trashed.map do |n|
      n.info_for_table
    end
  end

  def list_children
    self.children.asc(:created_at).map do |n|
      n.info_for_table
    end
  end

  def self.list_recent(amount = 20)
    self.where(:_type.in => [Homework, Share, Slide]).desc(:updated_at).limit(amount).map do |n|
      n.info_for_table
    end
  end

  def self.list_homeworks
    self.where(:_type.in => [Homework, Share]).asc(:created_at).map do |n|
      n.info_for_table
    end
  end

  def self.list_shares
    self.where(_type: Share).asc(:created_at).map do |n|
      n.info_for_table
    end
  end

  def self.list_slides
    self.where(_type: Slide).asc(:created_at).map do |n|
      n.info_for_table
    end
  end

  def self.list_starred
    self.starred.asc(:created_at).map do |n|
      n.info_for_table
    end
  end

  def self.search(keyword)
    self.where(name: /#{keyword}/).asc(:created_at).map do |n|
      n.info_for_table
    end
  end

  def info_for_table
    node = {
      node_type: self._type,
      id: self.id.to_s,
      name: self.name,
      last_update_time: self.last_update_time,
      starred: self.starred,
    }
    node[:subject] = Subject::NAME[self.subject] if self._type != "Folder"
    node[:owner] = self._type == "Share" ? self.find_node.user.name : "我"
    if self._type == "Share"
      node[:authority] = self.editable ? "可编辑" : "不可编辑"
    else
      node[:authority] = "可编辑"
    end
    node
  end

  def destroy_with_children
    if self.is_a? Folder
      self.children.unscoped.each do |e|
        e.destroy_with_children
      end
    end
    self.shares.unscoped.destroy_all
    self.destroy
  end
end
