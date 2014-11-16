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

  def list
  	nodes = [ ]
  	self.children.each do |f|
  		nodes << { type: "folder", node: f }
  	end
  	self.homeworks.each do |h|
  		nodes << { type: "homework", node: h }
  	end
  	nodes
  end
end
