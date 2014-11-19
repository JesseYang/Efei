# encoding: utf-8
class Folder
  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::Trashable

  field :name, type: String, default: "我的文件夹"
  field :is_root, type: Boolean, default: false
  has_many :homeworks, class_name: "Homework", inverse_of: :folder
  has_many :children, class_name: "Folder", inverse_of: :parent
  belongs_to :parent, class_name: "Folder", inverse_of: :children
  belongs_to :user, class_name: "User", inverse_of: :folders

  def self.folder_tree(user, parent_id = nil)
    tree = [ ]
    parent = parent_id.nil? ? user.root_folder : user.folders.find(parent_id)
    tree = {
      id: parent.id.to_s,
      name: parent.name,
      children: []
    }
    collection = parent.children
    collection.each do |n|
      tree[:children] << self.folder_tree(user, n.id)
    end
    tree
  end

  def ancestor_chain
    self.is_root ? [self] : self.parent.ancestor_chain + [self]
  end

  def touch_ancestor
    self.parent.try :touch_ancestor
    self.touch
  end

  def folder_path
    path = self.parent.try(:folder_path) || []
    path << { id: self.id.to_s, name: self.name }
    path
  end

  def self.create_new(user, name, parent_id = nil)
    f = user.folders.create(name: name)
    parent = parent_id == "root" ? user.root_folder : user.folders.find(parent_id)
    f.update_attribute :parent_id, parent.id
    f
  end

  def move_to(user, des_folder_id)
    des_folder = des_folder_id == "root" ? user.root_folder : user.folders.find(des_folder_id)
    self.update_attribute :parent_id, des_folder.id
  end

  def self.list_trash
    self.trashed.map do |f|
      {
        folder: true,
        id: f.id.to_s,
        name: f.name,
        last_update_time: f.last_update_time
      }
    end
  end

  def list_nodes
    nodes = [ ]
    self.children.each do |f|
      nodes << {
        folder: true,
        id: f.id.to_s,
        name: f.name,
        last_update_time: f.last_update_time
      }
    end
    self.homeworks.each do |h|
      nodes << {
        id: h.id.to_s,
        name: h.name,
        last_update_time: h.last_update_time,
        subject: Subject::NAME[h.subject]
      }
    end
    nodes
  end

  def last_update_time
    homework_time = self.homeworks.map { |e| e.updated_at } .to_a
    folder_time = self.children.map { |e| e.updated_at } .to_a
    time = ( homework_time + folder_time + [self.updated_at] ).max
    time.today? ? time.strftime("%H点%M分") : time.strftime("%Y年%m月%d日")
  end
end
