# encoding: utf-8
class Node
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::Trashable
  include Concerns::Starred
  field :name, type: String
  belongs_to :user, class_name: "User", inverse_of: :slides
  belongs_to :parent, class_name: "Folder", inverse_of: :children

  def last_update_time
    self.updated_at.today? ? self.updated_at.strftime("%H点%M分") : self.updated_at.strftime("%Y年%m月%d日")
  end

  def self.list_trash
    self.trashed.map do |n|
      node = {
        node_type: n._type,
        id: n.id.to_s,
        name: n.name,
        last_update_time: n.last_update_time
      }
      node[:subject] = Subject::NAME[n.subject] if n._type != "Folder"
      node
    end
  end

  def list_children
    self.children.map do |n|
      node = {
        node_type: n._type,
        name: n.name,
        id: n.id.to_s,
        last_update_time: n.last_update_time,
        starred: n.starred
      }
      node[:subject] = Subject::NAME[n.subject] if n._type != "Folder"
      node
    end
  end

  def self.list_recent(amount = 20)
    self.where(:_type.in => [Homework, Slide]).desc(:updated_at).limit(amount).map do |n|
      node = {
        node_type: n._type,
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject],
        starred: h.starred
      }
      node[:subject] = Subject::NAME[n.subject] if n._type != "Folder"
      node
    end
  end

  def self.list_starred
    self.starred.map do |n|
      node = {
        node_type: n._type,
        id: n.id.to_s,
        name: n.name,
        last_update_time: n.last_update_time,
        starred: n.starred
      }
      node[:subject] = Subject::NAME[n.subject] if n._type != "Folder"
      node
    end
  end

  def self.search(keyword)
    self.where(name: /#{keyword}/).map do |n|
      node = {
        node_type: n._type,
        id: n.id.to_s,
        name: n.name,
        last_update_time: n.last_update_time,
        starred: n.starred
      }
      node[:subject] = Subject::NAME[n.subject] if n._type != "Folder"
      node
    end
  end
end
